//
//  Trustlist.swift
//  
//
//  Created by Dominik Mocher on 29.04.21.
//

import Foundation

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

