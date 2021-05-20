//
//  Trustlist.swift
//  
//
//  Created by Dominik Mocher on 29.04.21.
//

import Foundation
import SwiftCBOR
import ASN1Decoder

struct TrustList : Codable {
    let entries : [TrustEntry]
    var hash: Data?
    
    enum CodingKeys: String, CodingKey {
        case entries = "c"
        case hash = "signatureHash"
    }
    
    init() {
        entries = [TrustEntry]()
    }
    
    func entry(for keyId: Data) -> TrustEntry? {
        return entries.first(where: { entry in entry.keyId == keyId})
    }
}

public struct TrustEntry : Codable {
    let cert: Data
    let keyId: Data
    
    private let OID_TEST = "1.3.6.1.4.1.0.1847.2021.1.1"
    private let OID_VACCINATION = "1.3.6.1.4.1.0.1847.2021.1.2"
    private let OID_RECOVERY = "1.3.6.1.4.1.0.1847.2021.1.3"
    
    enum CodingKeys: String, CodingKey {
        case cert = "c"
        case keyId = "i"
    }
    
    public init(cert: Data){
        self.cert = cert
        self.keyId = Data()
    }
    
    public func isSuitable(for certType: CertType) -> Bool {
        guard let certificate = try? X509Certificate(data: cert) else {
            return false
        }
        if isType(in: certificate) {
            switch certType {
            case .test:
                return nil != certificate.extensionObject(oid: OID_TEST)
            case .vaccination:
                return nil != certificate.extensionObject(oid: OID_VACCINATION)
            case .recovery:
                return nil != certificate.extensionObject(oid: OID_RECOVERY)
            }
        }
        return true
    }
    
    public var publicKey : SecKey? {
        get {
            if let certificate = SecCertificateCreateWithData(nil, cert as CFData) {
                return SecCertificateCopyKey(certificate)
            }
            return nil
        }
    }
    
    public func isValid(for dateService: DateService) -> Bool {
        guard let certificate = try? X509Certificate(data: cert) else {
            return false
        }
        return certificate.checkValidity(dateService.now)
    }
    
    private func isType(in certificate: X509Certificate) -> Bool {
        return nil != certificate.extensionObject(oid: OID_TEST)
            || nil != certificate.extensionObject(oid: OID_VACCINATION)
            || nil != certificate.extensionObject(oid: OID_RECOVERY)
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

