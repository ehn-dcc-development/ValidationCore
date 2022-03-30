//
//  CWT.swift
//  
//
//  Created by Dominik Mocher on 29.04.21.
//

import Foundation
import SwiftCBOR

public struct CWT {
    let iss : String?
    let exp : UInt64?
    let iat : UInt64?
    let nbf : UInt64?
    let sub : Data?
    public var healthCert : HealthCert?
    
    enum PayloadKeys : Int {
        case iss = 1
        case sub = 2
        case exp = 4
        case nbf = 5
        case iat = 6
        case hcert = -260
        
        enum HcertKeys : Int {
            case euHealthCertV1 = 1
        }
    }
    
    init?(from cbor: CBOR) {
        guard let decodedPayload = cbor.decodeBytestring()?.asMap() else {
            return nil
        }
        iss = decodedPayload[PayloadKeys.iss]?.asString()
        exp = decodedPayload[PayloadKeys.exp]?.asUInt64() ?? decodedPayload[PayloadKeys.exp]?.asDouble()?.toUInt64()
        iat = decodedPayload[PayloadKeys.iat]?.asUInt64() ?? decodedPayload[PayloadKeys.iat]?.asDouble()?.toUInt64()
        nbf = decodedPayload[PayloadKeys.nbf]?.asUInt64() ?? decodedPayload[PayloadKeys.nbf]?.asDouble()?.toUInt64()
        sub = decodedPayload[PayloadKeys.sub]?.asData()
        
        var healthCert : HealthCert? = nil
        if let hCertMap = decodedPayload[PayloadKeys.hcert]?.asMap(),
           let certData = hCertMap[PayloadKeys.HcertKeys.euHealthCertV1]?.asData() {
            healthCert = try? CodableCBORDecoder().decode(HealthCert.self, from: certData)
        }
        self.healthCert = healthCert
    }
    
    public var issuedAt : Date? {
        get {
            return iat?.toDate()
        }
    }
    
    public var notBefore : Date? {
        get {
            return nbf?.toDate()
        }
    }
    
    public var expiresAt : Date? {
        get {
            return exp?.toDate()
        }
    }
    
    
    func isValid(using dateService: DateService) -> Bool {
        guard let expDate = exp?.toDate() else {
            return false
        }
        var isValid = dateService.isNowBefore(expDate)
        if let iatDate = iat?.toDate() {
            isValid = isValid && dateService.isNowAfter(iatDate)
        }
        if let nbfDate = nbf?.toDate() {
            isValid = isValid && dateService.isNowAfter(nbfDate)
        }
        return isValid
    }
    
    func isAlreadyValid(using dateService: DateService) -> Bool {
        guard nil != iat || nil != nbf else {
            return false
        }
        var isValid = true
        if let iatDate = iat?.toDate() {
            isValid = isValid && dateService.isNowAfter(iatDate)
        }
        if let nbfDate = nbf?.toDate() {
            isValid = isValid && dateService.isNowAfter(nbfDate)
        }
        return isValid
    }
    
    func isNotExpired(using dateService: DateService) -> Bool {
        guard let expDate = exp?.toDate() else {
            return false
        }
        return dateService.isNowBefore(expDate)
    }
}

// MARK: - Encodable

extension CWT : Encodable {
    enum Codingkeys: String, CodingKey {
        case iss = "iss"
        case exp = "exp"
        case iat = "iat"
        case nbf = "nbf"
        case sub = "sub"
        case healthCert = "dgc"
    }
    
    func asJson() -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let jsonData = try? encoder.encode(self) else {
           return nil
        }
        return String(data: jsonData, encoding: .utf8)
    }
}
