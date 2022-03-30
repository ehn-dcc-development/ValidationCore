//
//  Trustlist.swift
//  
//
//  Created by Dominik Mocher on 29.04.21.
//

import Foundation
import SwiftCBOR
import ASN1Decoder
import CocoaLumberjackSwift

public struct TrustList : SignedData, Codable {
    public let entries : [TrustEntry]
    public var hash: Data?
    
    enum CodingKeys: String, CodingKey {
        case entries = "c"
        case hash = "signatureHash"
    }
    
    public init() {
        entries = [TrustEntry]()
    }
    
    public func entry(for keyId: Data) -> TrustEntry? {
        return entries.first(where: { entry in entry.keyId == keyId})
    }
    
    public var isEmpty: Bool {
        return entries.isEmpty
    }
}

public struct TrustEntry : Codable {
    let cert: Data
    let keyId: Data
    
    private let OID_TEST = "1.3.6.1.4.1.1847.2021.1.1"
    private let OID_ALT_TEST = "1.3.6.1.4.1.0.1847.2021.1.1"
    private let OID_VACCINATION = "1.3.6.1.4.1.1847.2021.1.2"
    private let OID_ALT_VACCINATION = "1.3.6.1.4.1.0.1847.2021.1.2"
    private let OID_RECOVERY = "1.3.6.1.4.1.1847.2021.1.3"
    private let OID_ALT_RECOVERY = "1.3.6.1.4.1.0.1847.2021.1.3"

    enum CodingKeys: String, CodingKey {
        case cert = "c"
        case keyId = "i"
    }
    
    public init(cert: Data, keyId: Data = Data()){
        self.cert = cert
        self.keyId = keyId
    }
    
    public func isSuitable(for certType: CertType) -> Bool {
        guard let certificate = try? X509Certificate(data: cert) else {
            return false
        }
        if isType(in: certificate) {
            switch certType {
            case .test:
                return nil != certificate.extensionObject(oid: OID_TEST) || nil != certificate.extensionObject(oid: OID_ALT_TEST)
            case .vaccination:
                return nil != certificate.extensionObject(oid: OID_VACCINATION) || nil != certificate.extensionObject(oid: OID_ALT_VACCINATION)
            case .recovery:
                return nil != certificate.extensionObject(oid: OID_RECOVERY) || nil != certificate.extensionObject(oid: OID_ALT_RECOVERY)
            case .vaccinationExemption:
                return false 
            }
        }
        DDLogDebug("Using trustlist certificate \(self.cert.base64EncodedString()) for validation")
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
    
    public var notBefore : Date? {
        guard let certificate = try? X509Certificate(data: cert) else {
            return nil
        }
        return certificate.notBefore
    }
    
    public var notAfter : Date? {
        guard let certificate = try? X509Certificate(data: cert) else {
            return nil
        }
        return certificate.notAfter
    }
    
    public func isValid(for dateService: DateService) -> Bool {
        guard let certificate = try? X509Certificate(data: cert) else {
            return false
        }
        return certificate.checkValidity(dateService.now)
    }
    
    public var debugInformation : SignatureCertInfo {
        return SignatureCertInfo(certDer: cert.asHex(useSpaces: false), certBase64: cert.base64EncodedString(), cert: readableCertInfo(), keyId: self.keyId.asHex(useSpaces: false))
    }
    
    private func isType(in certificate: X509Certificate) -> Bool {
        return nil != certificate.extensionObject(oid: OID_TEST)
            || nil != certificate.extensionObject(oid: OID_VACCINATION)
            || nil != certificate.extensionObject(oid: OID_RECOVERY)
            || nil != certificate.extensionObject(oid: OID_ALT_TEST)
            || nil != certificate.extensionObject(oid: OID_ALT_VACCINATION)
            || nil != certificate.extensionObject(oid: OID_ALT_RECOVERY)
    }
    
    private func readableCertInfo() -> String {
        guard let x509Cert = try? X509Certificate(data: cert) else {
            return ""
        }
        let placeholder = "<N/A>"
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withSpaceBetweenDateAndTime, .withFullDate, .withFullTime, .withTimeZone]
        let sigAlg = x509Cert.sigAlgName ?? x509Cert.sigAlgOID ?? placeholder
        var serial = placeholder
        if let serialNumber = x509Cert.serialNumber?.asHex(useSpaces: false) {
            serial = "0x\(serialNumber)"
        }
        var notBefore = placeholder
        if let notBeforeDate = x509Cert.notBefore {
            notBefore = dateFormatter.string(from: notBeforeDate)
        }
        var notAfter = placeholder
        if let notAfterDate = x509Cert.notAfter {
            notAfter = dateFormatter.string(from: notAfterDate)
        }
        var version = placeholder
        if let certVersion = x509Cert.version {
            version = "\(certVersion)"
        }
        let issuer = x509Cert.issuerDistinguishedName ?? placeholder
        let criticalExtensionOIDs = "\(x509Cert.criticalExtensionOIDs)"
        let nonCriticalExtensionOIDs = "\(x509Cert.nonCriticalExtensionOIDs)"
        let subject = x509Cert.subjectDistinguishedName ?? placeholder
        return """
               Subject: \(subject)
               Not Before: \(notBefore)
               Not After: \(notAfter)
               Issuer: \(issuer)
               Version: \(version)
               Serial: \(serial)
               Signature Alg: \(sigAlg)
               Critical Extension OIDs: \(criticalExtensionOIDs)
               Noncritical Extension OIDs: \(nonCriticalExtensionOIDs)
               """
    }
}

public enum CertType : String, Codable {
    case test = "t"
    case recovery = "r"
    case vaccination = "v"
    case vaccinationExemption = "ve"
}

enum KeyType : String, Codable {
    case ec = "e"
    case rsa = "r"
}

