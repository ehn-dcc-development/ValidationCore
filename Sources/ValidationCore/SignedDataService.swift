//
//  SignedDataService.swift
//  
//
//  Created by Martin Fitzka-Reichart on 14.07.21.
//

import Foundation
import SwiftCBOR
import CocoaLumberjackSwift
import Security

protocol SignedData: Codable {
    var hash: Data? { get set }
    var isEmpty: Bool { get }
    init()
}

class SignedDataService<T: SignedData> {
    private let dataUrl: String
    private let signatureUrl: String
    private let trustAnchor: String
    let dateService : DateService
    private let fileStorage : FileStorage
    var cachedData: T
    private let updateInterval: TimeInterval
    var lastUpdate : Date {
        get {
            if let isoDate = UserDefaults().string(forKey: self.lastUpdateKey),
               let date = ISO8601DateFormatter().date(from: isoDate) {
                return date
            }
            return Date(timeIntervalSince1970: 0)
        }
        set {
            let isoDate = ISO8601DateFormatter().string(from: newValue)
            UserDefaults().set(isoDate, forKey: self.lastUpdateKey)
        }
    }

    private let fileName: String
    private let keyAlias: String
    private let legacyKeychainAlias: String
    private let lastUpdateKey: String

    init(dateService: DateService,
         dataUrl: String,
         signatureUrl: String,
         trustAnchor: String,
         updateInterval: TimeInterval,
         fileName: String,
         keyAlias: String,
         legacyKeychainAlias: String,
         lastUpdateKey: String
    ) {
        self.dataUrl = dataUrl
        self.signatureUrl = signatureUrl
        self.trustAnchor = trustAnchor
        self.fileStorage = FileStorage()
        self.dateService = dateService
        self.updateInterval = updateInterval
        self.fileName = fileName
        self.keyAlias = keyAlias
        self.legacyKeychainAlias = legacyKeychainAlias
        self.lastUpdateKey = lastUpdateKey
        self.cachedData = T()

        loadCachedData()
        if self.cachedData.isEmpty {
            lastUpdate = Date(timeIntervalSince1970: 0)
        }
        updateSignatureAndDataIfNecessary { _ in }
        removeLegacyKeychainData()
    }

    public func updateDataIfNecessary(completionHandler: @escaping (ValidationError?)->()) {
        if dateService.isNowBefore(lastUpdate.addingTimeInterval(updateInterval)) {
            DDLogDebug("Skipping data update...")
            completionHandler(nil)
            return
        }

        updateSignatureAndDataIfNecessary { error in
            if let error = error {
                DDLogError("Cannot refresh data: \(error)")
            }

            completionHandler(error)
        }
    }

    private func updateSignatureAndDataIfNecessary(completionHandler: @escaping (ValidationError?)->()) {
        updateDetachedSignature() { result in
            switch result {
            case .success(let hash):
                if hash != self.cachedData.hash {
                    self.updateData(for: hash, completionHandler)
                    return
                } else {
                    self.lastUpdate = self.dateService.now
                }
                completionHandler(nil)
            case .failure(let error):
                completionHandler(error)
            }
        }
    }

    private func updateData(for hash: Data, _ completionHandler: @escaping (ValidationError?)->()) {
        guard let request = self.defaultRequest(to: self.dataUrl) else {
            completionHandler(.TRUST_SERVICE_ERROR)
            return
        }

        URLSession.shared.dataTask(with: request) { body, response, error in
            guard self.isResponseValid(response, error), let body = body else {
                DDLogError("Cannot query signed data service")
                completionHandler(.TRUST_SERVICE_ERROR)
                return
            }
            guard self.refreshData(from: body, for: hash) else {
                self.lastUpdate = self.dateService.now

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
            guard let cose = Cose(from: body),
                  let trustAnchorKey = self.trustAnchorKey(),
                  cose.hasValidSignature(for: trustAnchorKey) else {
                completionHandler(.failure(.TRUST_LIST_SIGNATURE_INVALID))
                return
            }
            guard let cwt = CWT(from: cose.payload),
                  let trustlistHash = cwt.sub else {
                completionHandler(.failure(.TRUST_SERVICE_ERROR))
                return
            }
            guard cwt.isAlreadyValid(using: self.dateService) else {
                completionHandler(.failure(.TRUST_LIST_NOT_YET_VALID))
                return
            }

            guard cwt.isNotExpired(using: self.dateService) else {
                completionHandler(.failure(.TRUST_LIST_EXPIRED))
                return
            }

            completionHandler(.success(trustlistHash))
        }.resume()
    }

    private func refreshData(from data: Data, for hash: Data) -> Bool {
        guard let cbor = try? CBORDecoder(input: data.bytes).decodeItem(),
              var decodedData = try? CodableCBORDecoder().decode(T.self, from: cbor.asData()) else {
            return false
        }
        decodedData.hash = hash
        self.cachedData = decodedData
        storeData()
        return true
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

    private func trustAnchorKey() -> SecKey? {
        guard let certData = Data(base64Encoded: trustAnchor),
              let certificate = SecCertificateCreateWithData(nil, certData as CFData),
              let secKey = SecCertificateCopyKey(certificate) else {
            return nil
        }
        return secKey
    }

}

extension SignedDataService {

    // MARK: Cached Data Storage and Retrieval

    private func storeData() {
        guard let encodedData = try? JSONEncoder().encode(self.cachedData) else {
            DDLogError("Cannot encode data for storing")
            return
        }
        if #available(iOS 13.0, *) {
            CryptoService.createKeyAndEncrypt(data: encodedData, with: self.keyAlias, completionHandler: { result in
                switch result {
                case .success(let data):
                    if !self.fileStorage.writeProtectedFileToDisk(fileData: data, with: self.fileName) {
                        DDLogError("Cannot write data to disk")
                    }
                case .failure(let error): DDLogError(error)
                }
            })
        } else {
            storeLegacyData(encodedData: encodedData)
        }
    }

    func loadCachedData() {
        if #available(iOS 13.0, *) {
            if let encodedData = fileStorage.loadProtectedFileFromDisk(with: self.fileName) {
                CryptoService.decrypt(ciphertext: encodedData, with: self.keyAlias) { result in
                    switch result {
                        case .success(let plaintext):
                            if let data = try? JSONDecoder().decode(T.self, from: plaintext) {
                                self.cachedData = data
                            }
                        case .failure(let error): DDLogError("Cannot load cached trust list: \(error)")
                    }
                }
            }
        } else {
            self.loadCachedLegacyData()
        }
    }
}

extension SignedDataService {

    // MARK: iOS 12 support for missing CryptoKit

    func removeLegacyKeychainData() {
        let query = [kSecClass: kSecClassGenericPassword,
                     kSecAttrLabel: self.legacyKeychainAlias
        ] as [String: Any]
        SecItemDelete(query as CFDictionary)
    }

    private func storeLegacyData(encodedData: Data) {
        guard let accessFlags = SecAccessControlCreateWithFlags(
                kCFAllocatorDefault,
                kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
                [],
                nil) else {
            DDLogError(ValidationError.KEYSTORE_ERROR)
            return
        }
        let updateQuery = [kSecClass: kSecClassGenericPassword,
                     kSecAttrLabel: self.legacyKeychainAlias,
                     kSecAttrAccessControl: accessFlags] as [String: Any]

        let updateAttributes = [kSecValueData: encodedData] as [String:Any]

        let status = SecItemUpdate(updateQuery as CFDictionary, updateAttributes as CFDictionary)
        if status == errSecItemNotFound {
            let addQuery = [kSecClass: kSecClassGenericPassword,
                         kSecAttrLabel: self.legacyKeychainAlias,
                         kSecAttrAccessControl: accessFlags,
                         kSecValueData: encodedData] as [String: Any]
            let addStatus = SecItemAdd(addQuery as CFDictionary, nil)
            if addStatus != errSecSuccess {
                DDLogError(ValidationError.KEYSTORE_ERROR)
            }
        } else if status != errSecSuccess {
            DDLogError(ValidationError.KEYSTORE_ERROR)
        }
    }

    private func loadCachedLegacyData() {
        let query = [kSecClass: kSecClassGenericPassword,
                     kSecAttrLabel: self.legacyKeychainAlias,
                     kSecReturnData: true] as [String: Any]

        var item: CFTypeRef?
        switch SecItemCopyMatching(query as CFDictionary, &item) {
            case errSecSuccess:
                if let plaintext = item as? Data {
                    if let data = try? JSONDecoder().decode(T.self, from: plaintext) {
                        self.cachedData = data
                    }
                }

            default: DDLogError(ValidationError.KEYSTORE_ERROR)
        }
    }
}
