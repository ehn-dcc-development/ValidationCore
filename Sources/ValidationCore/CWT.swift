//
//  CWT.swift
//  
//
//  Created by Dominik Mocher on 29.04.21.
//

import Foundation
import SwiftCBOR

struct CWT {
    let iss : String?
    let exp : UInt64?
    let iat : UInt64?
    let nbf : UInt64?
    let sub : Data?
    let euHealthCert : EuHealthCert?

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
        exp = decodedPayload[PayloadKeys.exp]?.asUInt64()
        iat = decodedPayload[PayloadKeys.iat]?.asUInt64()
        nbf = decodedPayload[PayloadKeys.nbf]?.asUInt64()
        sub = decodedPayload[PayloadKeys.sub]?.asData()
        
        var euHealthCert : EuHealthCert? = nil
        if let hCertMap = decodedPayload[PayloadKeys.hcert]?.asMap(),
           let certData = hCertMap[PayloadKeys.HcertKeys.euHealthCertV1]?.asData() {
           euHealthCert = try? CodableCBORDecoder().decode(EuHealthCert.self, from: certData)
        }
        self.euHealthCert = euHealthCert
    }
    
    func isValid(using dateService: DateService) -> Bool {
        guard let exp = exp else {
            return false
        }
        let expDate = Date(timeIntervalSince1970: TimeInterval(exp))
        var isValid = dateService.isNowBefore(expDate)
        if let iat = iat {
           let iatDate = Date(timeIntervalSince1970: TimeInterval(iat))
            isValid = isValid && dateService.isNowAfter(iatDate)
        }
        if let nbf = nbf {
            let nbfDate = Date(timeIntervalSince1970: TimeInterval(nbf))
            isValid = isValid && dateService.isNowAfter(nbfDate)
        }
        return isValid
    }
}
