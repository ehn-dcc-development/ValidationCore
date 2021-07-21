//
//  File.swift
//  
//
//  Created by Dominik Mocher on 26.04.21.
//

import Foundation
import SwiftCBOR
import CocoaLumberjackSwift
import Security

public protocol TrustlistService {
    func key(for keyId: Data, keyType: CertType, completionHandler: @escaping (Result<SecKey, ValidationError>)->())
    func key(for keyId: Data, cwt: CWT, keyType: CertType, completionHandler: @escaping (Result<SecKey, ValidationError>)->())
    func updateTrustlistIfNecessary(completionHandler: @escaping (ValidationError?)->())
}

class DefaultTrustlistService : TrustlistService {
    private let trustlistUrl : String
    private let signatureUrl : String
    private let TRUSTLIST_FILENAME = "trustlist"
    private let TRUSTLIST_KEY_ALIAS = "trustlist_key"
    private let TRUSTLIST_KEYCHAIN_ALIAS = "trustlist_keychain"
    private let LAST_UPDATE_KEY = "last_trustlist_update"
    private let dateService : DateService
    private var cachedTrustlist : TrustList
    private let fileStorage : FileStorage
    private let trustlistAnchor : String
    private let updateInterval = TimeInterval(1.hour)
    private var lastUpdate : Date {
        get {
            if let isoDate = UserDefaults().string(forKey: LAST_UPDATE_KEY),
               let date = ISO8601DateFormatter().date(from: isoDate) {
                return date
            }
            return Date(timeIntervalSince1970: 0)
        }
        set {
            let isoDate = ISO8601DateFormatter().string(from: newValue)
            UserDefaults().set(isoDate, forKey: LAST_UPDATE_KEY)
        }
    }
    
    init(dateService: DateService, trustlistUrl: String, signatureUrl: String, trustAnchor: String) {
        self.trustlistUrl = trustlistUrl
        self.signatureUrl = signatureUrl
        trustlistAnchor = trustAnchor.normalizeCertificate()
        self.fileStorage = FileStorage()
        cachedTrustlist = TrustList()
        self.dateService = dateService
        self.loadCachedTrustlist()
        updateTrustlistIfNecessary() { _ in }
        removeiOS12LegacyTrustlist()
    }
    
    public func key(for keyId: Data, keyType: CertType, completionHandler: @escaping (Result<SecKey, ValidationError>)->()){
        key(for: keyId, keyType: keyType, cwt: nil, completionHandler: completionHandler)
    }
    
    public func key(for keyId: Data, cwt: CWT, keyType: CertType, completionHandler: @escaping (Result<SecKey, ValidationError>)->()){
        return key(for: keyId, keyType: keyType, cwt: cwt, completionHandler: completionHandler)
    }
    
    private func key(for keyId: Data, keyType: CertType, cwt: CWT?, completionHandler: @escaping (Result<SecKey, ValidationError>)->()){
        if dateService.isNowBefore(lastUpdate.addingTimeInterval(updateInterval)) {
            DDLogDebug("Skipping trustlist update...")
            cachedKey(from: keyId, for: keyType, cwt: cwt, completionHandler)
            return
        }
        
        updateTrustlistIfNecessary { error in
            if let error = error {
                DDLogError("Cannot refresh trust list: \(error)")
            }
            self.cachedKey(from: keyId, for: keyType, cwt: cwt, completionHandler)
        }
    }

    private func removeiOS12LegacyTrustlist() {
        let query = [kSecClass: kSecClassGenericPassword,
                     kSecAttrLabel: self.TRUSTLIST_KEYCHAIN_ALIAS
        ] as [String: Any]
        SecItemDelete(query as CFDictionary)
    }
    
    public func updateTrustlistIfNecessary(completionHandler: @escaping (ValidationError?)->()) {
        updateDetachedSignature() { result in
            switch result {
            case .success(let hash):
                self.lastUpdate = self.dateService.now
                if hash != self.cachedTrustlist.hash {
                    self.updateTrustlist(for: hash, completionHandler)
                    return
                }
                completionHandler(nil)
            case .failure(let error):
                completionHandler(error)
            }
        }
    }
    
    private func updateTrustlist(for hash: Data, _ completionHandler: @escaping (ValidationError?)->()) {
        guard let request = self.defaultRequest(to: self.trustlistUrl) else {
            completionHandler(.TRUST_SERVICE_ERROR)
            return
        }
        
        URLSession.shared.dataTask(with: request) { body, response, error in
            guard self.isResponseValid(response, error), let body = body else {
                DDLogError("Cannot query trustlist service")
                completionHandler(.TRUST_SERVICE_ERROR)
                return
            }
            guard self.refreshTrustlist(from: body, for: hash) else {
                completionHandler(.TRUST_SERVICE_ERROR)
                return
            }
            completionHandler(nil)
        }.resume()
    }
    
    private func updateDetachedSignature(completionHandler: @escaping (Result<Data, ValidationError>)->()) {
        guard let request = defaultRequest(to: signatureUrl) else {
            completionHandler(.failure(.TRUST_SERVICE_ERROR))
            return
        }
        
        URLSession.shared.dataTask(with: request) { body, response, error in
            guard self.isResponseValid(response, error), let body = body else {
                completionHandler(.failure(.TRUST_SERVICE_ERROR))
                return
            }
            do {
                let decoded = try DataDecoder().decode(signatureCose: body, trustAnchor: self.trustlistAnchor, dateService: self.dateService)
                let trustlistHash = decoded.content
                completionHandler(.success(trustlistHash))
            } catch let error {
                completionHandler(.failure(error as? ValidationError ?? .TRUST_SERVICE_ERROR))
                return
            }
       }.resume()
    }
    
    private func defaultRequest(to url: String) -> URLRequest? {
        guard let url = URL(string: url) else {
            return nil
        }
        var request = URLRequest(url: url)
        request.addValue("application/octet-stream", forHTTPHeaderField: "Accept")
        return request
    }
    
    private func isResponseValid(_ response: URLResponse?, _ error: Error?) -> Bool {
        guard error == nil,
              let status = (response as? HTTPURLResponse)?.statusCode,
              200 == status else {
            return false
        }
        return true
    }
    
    private func cachedKey(from keyId: Data, for keyType: CertType, cwt: CWT?, _ completionHandler: @escaping (Result<SecKey, ValidationError>)->()) {
        guard let entry = cachedTrustlist.entry(for: keyId) else {
            completionHandler(.failure(.KEY_NOT_IN_TRUST_LIST))
            return
        }
        guard entry.isValid(for: dateService) else {
            completionHandler(.failure(.PUBLIC_KEY_EXPIRED))
            return
        }
        guard entry.isSuitable(for: keyType) else {
            completionHandler(.failure(.UNSUITABLE_PUBLIC_KEY_TYPE))
            return
        }
        
        if let cwtIssuedAt = cwt?.issuedAt,
           let cwtExpiresAt = cwt?.expiresAt,
           let certNotBefore = entry.notBefore,
           let certNotAfter = entry.notAfter {
            guard certNotBefore.isBefore(cwtIssuedAt) && certNotAfter.isAfter(cwtIssuedAt) && certNotAfter.isAfter(cwtExpiresAt) else {
                completionHandler(.failure(.CWT_EXPIRED))
                return
            }
        }
        
        guard let secKey = entry.publicKey else {
            completionHandler(.failure(.KEY_CREATION_ERROR))
            return
        }
        completionHandler(.success(secKey))
    }
    
    private func refreshTrustlist(from data: Data, for hash: Data) -> Bool {
        guard let cbor = try? CBORDecoder(input: data.bytes).decodeItem(),
              var trustlist = try? CodableCBORDecoder().decode(TrustList.self, from: cbor.asData()) else {
            return false
        }
        trustlist.hash = hash
        self.cachedTrustlist = trustlist
        storeTrustlist()
        return true
    }
    
    private func storeTrustlist(){
        guard let trustlistData = try? JSONEncoder().encode(self.cachedTrustlist) else {
            DDLogError("Cannot encode trustlist for storing")
            return
        }
        if #available(iOS 13.0, *) {
            CryptoService.createKeyAndEncrypt(data: trustlistData, with: self.TRUSTLIST_KEY_ALIAS, completionHandler: { result in
                switch result {
                case .success(let data):
                    if !self.fileStorage.writeProtectedFileToDisk(fileData: data, with: self.TRUSTLIST_FILENAME) {
                        DDLogError("Cannot write trustlist to disk")
                    }
                case .failure(let error): DDLogError(error)
                }
            })
        } else {
            guard let accessFlags = SecAccessControlCreateWithFlags(
                    kCFAllocatorDefault,
                    kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
                    [],
                    nil) else {
                DDLogError(ValidationError.KEYSTORE_ERROR)
                return
            }
            let updateQuery = [kSecClass: kSecClassGenericPassword,
                         kSecAttrLabel: self.TRUSTLIST_KEYCHAIN_ALIAS,
                         kSecAttrAccessControl: accessFlags] as [String: Any]

            let updateAttributes = [kSecValueData: trustlistData] as [String:Any]

            let status = SecItemUpdate(updateQuery as CFDictionary, updateAttributes as CFDictionary)
            if status == errSecItemNotFound {
                let addQuery = [kSecClass: kSecClassGenericPassword,
                             kSecAttrLabel: self.TRUSTLIST_KEYCHAIN_ALIAS,
                             kSecAttrAccessControl: accessFlags,
                             kSecValueData: trustlistData] as [String: Any]
                let addStatus = SecItemAdd(addQuery as CFDictionary, nil)
                if addStatus != errSecSuccess {
                    DDLogError(ValidationError.KEYSTORE_ERROR)
                }
            } else if status != errSecSuccess {
                DDLogError(ValidationError.KEYSTORE_ERROR)
            }
        }
    }
    
    private func loadCachedTrustlist() {
        if #available(iOS 13.0, *) {
            if let trustlistData = fileStorage.loadProtectedFileFromDisk(with: TRUSTLIST_FILENAME) {
                CryptoService.decrypt(ciphertext: trustlistData, with: TRUSTLIST_KEY_ALIAS) { result in
                    switch result {
                        case .success(let plaintext):
                            if let trustlist = try? JSONDecoder().decode(TrustList.self, from: plaintext) {
                                self.cachedTrustlist = trustlist
                            }
                        case .failure(let error): DDLogError("Cannot load cached trust list: \(error)")
                    }
                }
            }
        } else {
            let query = [kSecClass: kSecClassGenericPassword,
                         kSecAttrLabel: self.TRUSTLIST_KEYCHAIN_ALIAS,
                         kSecReturnData: true] as [String: Any]

            var item: CFTypeRef?
            switch SecItemCopyMatching(query as CFDictionary, &item) {
                case errSecSuccess:
                    if let plaintext = item as? Data {
                        if let trustlist = try? JSONDecoder().decode(TrustList.self, from: plaintext) {
                            self.cachedTrustlist = trustlist
                        }
                    }

                default: DDLogError(ValidationError.KEYSTORE_ERROR)
            }
        }
    }
}
