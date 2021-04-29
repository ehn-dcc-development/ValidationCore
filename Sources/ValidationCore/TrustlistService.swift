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

class TrustlistService {
    private let CERT_SERVICE_URL = "https://dgc.a-sit.at/ehn/"
    private let TRUST_LIST_PATH = "cert/list"
    private let TRUSTLIST_FILENAME = "trustlist"
    private let TRUSTLIST_KEY_ALIAS = "trustlist_key"
    private var cachedTrustlist : TrustList
    private let fileStorage : FileStorage
    
    init() {
        self.fileStorage = FileStorage()
        cachedTrustlist = TrustList(validFrom: 0, validUntil: 0, entries: [])
        self.loadCachedTrustlist()
    }
    
    func key(for keyId: Data, keyType: CertType, completionHandler: @escaping (Result<SecKey, ValidationError>)->()){
        if cachedTrustlist.isValid() {
            cachedKey(from: keyId, for: keyType, completionHandler)
            return
        }
        updateTrustlist { error in
            if let error = error {
                DDLogError("Cannot refresh trust list: \(error)")
            }
            self.cachedKey(from: keyId, for: keyType, completionHandler)
        }
    }
    
    private func updateTrustlist(completionHandler: @escaping (Error?)->()) {
        guard let url = URL(string: "\(CERT_SERVICE_URL)\(TRUST_LIST_PATH)") else {
            DDLogError("Cannot construct certificate query url.")
            return
        }
        
        var request = URLRequest(url: url)
        request.addValue("application/octet-stream", forHTTPHeaderField: "Accept")
        URLSession.shared.dataTask(with: request) { body, response, error in
            guard error == nil,
                  let status = (response as? HTTPURLResponse)?.statusCode,
                  200 == status,
                  let body = body else {
                DDLogError("Cannot query certificate.")
                completionHandler(nil)
                return
            }
            guard self.refreshTrustlist(from: body) else {
                completionHandler(ValidationError.TRUST_SERVICE_ERROR)
                return
            }
            completionHandler(nil)
        }.resume()
    }
    
    private func cachedKey(from keyId: Data, for keyType: CertType, _ completionHandler: @escaping (Result<SecKey, ValidationError>)->()) {
        guard let entry = cachedTrustlist.entry(for: keyId) else {
            completionHandler(.failure(.KEY_NOT_IN_TRUST_LIST))
            return
        }
        guard entry.isSuitable(for: keyType) else {
            completionHandler(.failure(.UNSUITABLE_KEY_TYPE))
            return
        }
        guard let secKey = entry.publicKey else {
            completionHandler(.failure(.KEY_CREATION_ERROR))
            return
        }
        completionHandler(.success(secKey))
    }
    
    private func refreshTrustlist(from data: Data) -> Bool {
        guard let cose = Cose(from: data),
              let cbor = cose.payload.decodeBytestring(),
              let trustlist = try? CodableCBORDecoder().decode(TrustList.self, from: Data(cbor.encode())),
              trustlist.isValid() else {
            return false
        }
        self.cachedTrustlist = trustlist
        storeTrustlist()
        return true
    }
    
    private func storeTrustlist(){
        guard let trustlistData = try? JSONEncoder().encode(self.cachedTrustlist) else {
            DDLogError("Cannot encode trustlist for storing")
            return
        }
        CryptoService.createKeyAndEncrypt(data: trustlistData, with: self.TRUSTLIST_KEY_ALIAS, completionHandler: { result in
            switch result {
            case .success(let data):
                self.fileStorage.writeProtectedFileToDisk(fileData: data, with: self.TRUSTLIST_FILENAME)
            case .failure(let error): DDLogError(error)
            }
        })
    }
    
    private func loadCachedTrustlist(){
        if let trustlistData = fileStorage.loadProtectedFileFromDisk(with: TRUSTLIST_FILENAME) {
            CryptoService.decrypt(ciphertext: trustlistData, with: TRUSTLIST_KEY_ALIAS) { result in
                switch result {
                case .success(let plaintext):
                    if let trustlist = try? JSONDecoder().decode(TrustList.self, from: plaintext),
                       trustlist.isValid() {
                        self.cachedTrustlist = trustlist
                    }
                case .failure(let error): DDLogError("Cannot load cached trust list: \(error)")
                }
            }
        }
    }
}

struct TrustList : Codable {
    let validFrom : UInt64
    let validUntil : UInt64
    let entries : [TrustEntry]
    
    enum CodingKeys: String, CodingKey {
        case validFrom = "f"
        case validUntil = "u"
        case entries = "c"
    }
    
    func isValid() -> Bool {
        let now = Date()
        let validFromDate = Date(timeIntervalSince1970: TimeInterval(validFrom))
        let validUntilDate = Date(timeIntervalSince1970: TimeInterval(validUntil))
        guard now.isAfter(validFromDate),
              now.isBefore(validUntilDate) else {
            return false
        }
        return true
    }
    
    func entry(for keyId: Data) -> TrustEntry? {
        return entries.first(where: { entry in entry.keyId == keyId})
    }
}

struct TrustEntry : Codable {
    let validUntil : UInt64
    let validFrom : UInt64
    let publicKeyData : Data
    let keyId : Data
    let keyType :  KeyType
    let certType : [CertType]
    
    enum CodingKeys: String, CodingKey {
        case publicKeyData = "p"
        case validUntil = "u"
        case keyType = "k"
        case certType = "t"
        case validFrom = "f"
        case keyId = "i"
    }
    
    public func isSuitable(for certType: CertType) -> Bool {
        return self.certType.contains(certType)
    }
    
    var publicKey : SecKey? {
        get {
            var attributes : [CFString:Any]
            switch keyType {
            case .ec:
                attributes = [kSecAttrKeyClass: kSecAttrKeyClassPublic,
                              kSecAttrKeyType: kSecAttrKeyTypeEC,
                              kSecAttrKeySizeInBits: 256]
            case .rsa:
                attributes = [kSecAttrKeyClass: kSecAttrKeyClassPublic,
                              kSecAttrKeyType: kSecAttrKeyTypeRSA,
                              kSecAttrKeySizeInBits: 2048]
            }
            return SecKeyCreateWithData(publicKeyData as CFData, attributes as CFDictionary, nil)
        }
    }
}

public enum CertType : String, Codable {
    case test = "t"
    case recovery = "r"
    case vaccination = "v"
}

enum KeyType : String, Codable {
    case ec = "e"
    case rsa = "r"
}

extension Date {
    func isBefore(_ date: Date) -> Bool {
        return distance(to: date) > 0
    }
    func isAfter(_ date: Date) -> Bool {
        return distance(to: date) < 0
    }
}
