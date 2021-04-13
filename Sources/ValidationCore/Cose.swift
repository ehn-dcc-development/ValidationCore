//
//  Cose.swift
//  
//
//  Created by Dominik Mocher on 07.04.21.
//

import Foundation
import SwiftCBOR
import CocoaLumberjackSwift
import CryptoKit

struct Cose {
    let header : CoseHeader
    let payload : CWT
    let signature : Data
    let rawHeader : [UInt8]? //TODO make private, use for constructing data type
    let rawPayload : [UInt8]? //TODO make private, represents cwt
    
    private var signatureStruct : Data? {
        get {
           /* From https://tools.ietf.org/html/rfc8152#section-4.2
             Sig_structure = [
                 context : "Signature" / "Signature1" / "CounterSignature",
                 body_protected : empty_or_serialized_map,
                 ? sign_protected : empty_or_serialized_map,
                 external_aad : bstr,
                 payload : bstr
             ]
             */
            let context = CBOR(stringLiteral: "Signature1")
            guard let rawHeader = rawHeader,
                  let protectedHeader = try? CBORDecoder(input: CBOR.encodeData(Data(rawHeader))).decodeItem(),
                  let rawPayload = rawPayload,
                  let payloadCbor = try? CBORDecoder(input: CBOR.encodeData(Data(rawPayload))).decodeItem() else {
                return nil
            }
            let externalAad = CBOR.byteString([UInt8]()) /*no external application specific data*/
            let cborArray = CBOR(arrayLiteral: context, protectedHeader, externalAad, payloadCbor)
            return Data(cborArray.encode())
        }
    }

    //Only supporting ES256 signatures for the moment
    func hasValidSignature(for encodedCert: String?) -> Bool {
        guard let encodedCert = encodedCert else {
            DDLogError("No certificate, assuming COSE is not valid.")
            return false
        }
        guard let signedData = signatureStruct,
              let encodedCertData = Data(base64Encoded: encodedCert),
              let cert = SecCertificateCreateWithData(nil, encodedCertData as CFData),
              let extractedKey = SecCertificateCopyKey(cert) else {
            DDLogError("Cannot decode certificate.")
            return false
        }

        let asn1Signature = Asn1Encoder().convertRawSignatureIntoAsn1(signature)
        var error : Unmanaged<CFError>?
        let result = SecKeyVerifySignature(extractedKey, .ecdsaSignatureMessageX962SHA256, signedData as CFData, asn1Signature as CFData, &error)
        if let error = error {
            DDLogError("Signature verification error: \(error)")
        }
        return result
    }
}

struct CWT {
//    let header : CoseHeader
    let payload : CBOR
    let iss : String?
    let exp : UInt64?
    let iat : UInt64?
    let euHealthCert : EuHealthCert
    
    enum PayloadKeys : Int {
        case iss = 1
        case iat = 6
        case exp = 4
        case hcert = 99
        
        enum HcertKeys : Int {
            case euHealthCertV1 = 1
        }
        
        func toCbor() -> CBOR {
            return CBOR(integerLiteral: self.rawValue)
        }
    }

    init?(from cbor: CBOR) {
        payload = cbor
        iss = cbor[PayloadKeys.iss.toCbor()]?.asString()
        exp = cbor[PayloadKeys.exp.toCbor()]?.asUInt64()
        iat = cbor[PayloadKeys.iat.toCbor()]?.asUInt64()
        guard let encodedMap = cbor[PayloadKeys.hcert.toCbor()]?.encode(),
              let hCertMap = try? CBORDecoder(input: encodedMap).decodeItem(),
              let dataBytes = hCertMap[CBOR(integerLiteral: PayloadKeys.HcertKeys.euHealthCertV1.rawValue)]?.asBytes(),
              let certData = try? CBORDecoder(input: dataBytes).decodeItem() else {
            return nil
        }
        
        euHealthCert = EuHealthCert(from: certData)
    }
}

struct CoseHeader {
    var keyId : String
    var algorithm : Int
    
    enum Headers : Int {
        case keyId = 4
        case algorithm = 1
    }
    
    init?(from object: NSObject?){
        guard let dict = object as? [Int: NSObject],
              let keyId = dict[Headers.keyId.rawValue] as? String,
              let algorithm = dict[Headers.algorithm.rawValue] as? Int
              else {
            return nil
        }
        self.keyId = keyId
        self.algorithm = algorithm
    }
}




public struct EuHealthCert {
    public let person: Person?
    public let vaccinations: [Vaccination]?
    public let pastInfections: [PastInfection]?
    public let tests: [Test]?
    public let certificateMetadata: CertificateMetadata?
    
    
    init(from cbor: CBOR) {
        person = Person(from: cbor["sub"])
        vaccinations = (cbor["vac"]?.asList())?.compactMap { Vaccination(from: $0) } ?? nil
        pastInfections = (cbor["rec"]?.asList())?.compactMap { PastInfection(from: $0) } ?? nil
        tests = (cbor["tst"]?.asList())?.compactMap { Test(from: $0) } ?? nil
        certificateMetadata = CertificateMetadata(from: cbor["cert"])
    }
}

public struct Person {
    public let givenName: String?
    public let familyName: String?
    public let birthDate: String?
    public let identifier: [Identifier?]?
    
    init?(from cbor: CBOR?) {
        guard let cbor = cbor else {
            return nil
        }
        givenName = cbor["gn"]?.asString()
        familyName = cbor["fn"]?.asString()
        birthDate = cbor["dob"]?.asString()
        identifier = (cbor["id"]?.asList())?.compactMap { Identifier(from: $0) } ?? nil
    }
}

public struct Identifier {
    public let system: String?
    public let value: String?
    
    init?(from cbor: CBOR?) {
        guard let cbor = cbor else {
            return nil
        }
        system = cbor["t"]?.asString()
        value = cbor["i"]?.asString()
    }
}

public struct Vaccination {
    public let disease: String?
    public let vaccine: String?
    public let medicinialProduct: String?
    public let marketingAuthorizationHolder: String?
    public let number: UInt64?
    public let numberOf: UInt64?
    public let lotNumber: String?
    public let vaccinationDate: String?
    public let administeringCentre: String?
    public let country: String?
    
    init?(from cbor: CBOR?) {
        guard let cbor = cbor else {
            return nil
        }
        disease = cbor["dis"]?.asString()
        vaccine = cbor["vap"]?.asString()
        medicinialProduct = cbor["mep"]?.asString()
        marketingAuthorizationHolder = cbor["aut"]?.asString()
        number = cbor["seq"]?.asUInt64()
        numberOf = cbor["tot"]?.asUInt64()
        lotNumber = cbor["lot"]?.asString()
        vaccinationDate = cbor["dat"]?.asString()
        administeringCentre = cbor["adm"]?.asString()
        country = cbor["cou"]?.asString()
    }
}

public struct PastInfection {
    public let disease: String?
    public let dateFirstPositiveTest: String?
    public let countryOfTest: String?
    
    init?(from cbor: CBOR?) {
        guard let cbor = cbor else {
            return nil
        }
        disease = cbor["dis"]?.asString()
        countryOfTest = cbor["cou"]?.asString()
        dateFirstPositiveTest = cbor["dat"]?.asString()
    }
}

public struct CertificateMetadata {
    public let issuer: String?
    public let identifier: String?
    public let validFrom: String?
    public let validUntil: String?
    public let validUntilextended: String?
    public let revokelistidentifier: String?
    public let schemaVersion: String?
    public let country: String?
    
    init?(from cbor: CBOR?) {
        guard let cbor = cbor else {
            return nil
        }
        identifier = cbor["id"]?.asString()
        issuer = cbor["is"]?.asString()
        validFrom = cbor["vf"]?.asString()
        schemaVersion = cbor["vr"]?.asString()
        validUntil = cbor["vu"]?.asString()
        validUntilextended = cbor["validUntilextended"]?.asString()
        revokelistidentifier = cbor["revokelistidentifier"]?.asString()
        country = cbor["co"]?.asString()
    }
}

public struct Test : Decodable {
    public let disease: String?
    public let type: String?
    public let name: String?
    public let manufacturer: String?
    public let sampleOrigin: String?
    public let timestampSample: String?
    public let timestampResult : String?
    public let result: String?
    public let facility: String?
    public let country: String?

    init?(from cbor: CBOR?) {
        guard let cbor = cbor else {
            return nil
        }
        disease = cbor["dis"]?.asString()
        type = cbor["typ"]?.asString()
        name = cbor["tna"]?.asString()
        manufacturer = cbor["tma"]?.asString()
        sampleOrigin = cbor["ori"]?.asString()
        timestampSample = cbor["dts"]?.asString()
        timestampResult = cbor["dtr"]?.asString() 
        result = cbor["res"]?.asString()
        facility = cbor["fac"]?.asString()
        country = cbor["cou"]?.asString()
    }
}


extension ValidationCore {
    func decodePayload(from object: NSObject) -> CWT? {
        guard let payload = object.cborBytes,
              let decodedPayload = try? CBORDecoder(input: payload).decodeItem() else {
            DDLogError("Cannot decode COSE payload.")
            return nil
        }
        let cwt = CWT(from: decodedPayload)
        return cwt //VaccinationData(from: decodedPayload)
    }
}

extension CBOR {
    func unwrap() -> Any? {
        switch self {
        case .simple(let value): return value
        case .boolean(let value): return value
        case .byteString(let value): return value
        case .date(let value): return value
        case .double(let value): return value
        case .float(let value): return value
        case .half(let value): return value
        case .tagged(let tag, let cbor): return cbor  //TODO expand lib for COSE Sign1 and Sign tags and replace CBORSwift
        case .array(let array): return array
        case .map(let map): return map
        case .utf8String(let value): return value
        case .unsignedInt(let value): return value
        case .negativeInt(let value): return value
        default:
            return nil
        }
    }
    
    func asUInt64() -> UInt64? {
        return self.unwrap() as? UInt64
    }
    
    func asString() -> String? {
        return self.unwrap() as? String
    }
    
    func asList() -> [CBOR]? {
        return self.unwrap() as? [CBOR]
    }
    
    func asMap() -> [CBOR:CBOR]? {
        return self.unwrap() as? [CBOR:CBOR]
    }
    
    func asBytes() -> [UInt8]? {
        return self.unwrap() as? [UInt8]
    }
}
