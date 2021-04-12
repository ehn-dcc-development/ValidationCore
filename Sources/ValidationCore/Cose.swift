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
    let payload : VaccinationData
    let signature : Data
    let rawHeader : [UInt8]?
    let rawPayload : [UInt8]?
    
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
    func hasValidSignature(for encodedCert: String) -> Bool {
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




struct VaccinationData {
    var person: Person?
    var vaccinations: [Vaccination]?
    var pastInfection: PastInfection?
    var test: Test?
    var certificateMetadata: CertificateMetadata?
    
    init(from cbor: CBOR) {
        person = Person(from: cbor["sub"])
        
        if let cborVaccinations = cbor["vac"]?.unwrap() as? [CBOR] {
            vaccinations = cborVaccinations.compactMap { Vaccination(from: $0) }
        }
        pastInfection = PastInfection(from: cbor["rec"])
        test = Test(from: cbor["tst"])
        certificateMetadata = CertificateMetadata(from: cbor["cert"])
    }
}

struct Person {
    var name: String?
    var birthDate: String?
    var identifier: [Identifier?]?
    
    init?(from cbor: CBOR?) {
        guard let cbor = cbor else {
            return nil
        }
        name = cbor["n"]?.unwrap() as? String
        birthDate = cbor["dob"]?.unwrap() as? String
        if let cborIds = cbor["id"]?.unwrap() as? [CBOR]{
            identifier = cborIds.compactMap { Identifier(from: $0) }
        }
    }
}

struct Identifier {
    var system: String?
    var value: String?
    
    init?(from cbor: CBOR?) {
        guard let cbor = cbor else {
            return nil
        }
        system = cbor["t"]?.unwrap() as? String
        value = cbor["i"]?.unwrap() as? String
    }
}

struct Vaccination {
    var disease: String?
    var vaccine: String?
    var medicinialProduct: String?
    var marketingAuthorizationHolder: String?
    var manufacturer: String?
    var number: UInt64?
    var numberOf: UInt64?
    var lotNumber: String?
    var batch: String?
    var vaccinationDate: String?
    var nextVaccinationDate: String?
    var administeringCentre: String?
    var healthprofessionaIdentification: String?
    var countryOfVaccination: String?
    var country: String?
    
    init?(from cbor: CBOR?) {
        guard let cbor = cbor else {
            return nil
        }
        disease = cbor["dis"]?.unwrap() as? String
        vaccine = cbor["des"]?.unwrap() as? String
        medicinialProduct = cbor["nam"]?.unwrap() as? String
        marketingAuthorizationHolder = cbor["aut"]?.unwrap() as? String
        number = cbor["seq"]?.unwrap() as? UInt64
        numberOf = cbor["tot"]?.unwrap() as? UInt64
        lotNumber = cbor["lot"]?.unwrap() as? String
        vaccinationDate = cbor["dat"]?.unwrap() as? String
        administeringCentre = cbor["adm"]?.unwrap() as? String
        country = cbor["cou"]?.unwrap() as? String
    }
}

struct PastInfection {
    var disease: String?
    var dateFirstPositiveTest: String?
    var countryOfTest: String?
    
    init?(from cbor: CBOR?) {
        guard let cbor = cbor else {
            return nil
        }
        disease = cbor["dis"]?.unwrap() as? String
        countryOfTest = cbor["cou"]?.unwrap() as? String
        dateFirstPositiveTest = cbor["dat"]?.unwrap() as? String
    }
}

struct CertificateMetadata {
    var issuer: String?
    var identifier: String?
    var validFrom: String?
    var validUntil: String?
    var validUntilextended: String?
    var revokelistidentifier: String?
    var schemaVersion: String?
    var country: String?
    
    init?(from cbor: CBOR?) {
        guard let cbor = cbor else {
            return nil
        }
        identifier = cbor["id"]?.unwrap() as? String
        issuer = cbor["is"]?.unwrap() as? String
        validFrom = cbor["vf"]?.unwrap() as? String
        schemaVersion = cbor["vr"]?.unwrap() as? String
        validUntil = cbor["vu"]?.unwrap() as? String
        validUntilextended = cbor["validUntilextended"]?.unwrap() as? String
        revokelistidentifier = cbor["revokelistidentifier"]?.unwrap() as? String
        country = cbor["co"]?.unwrap() as? String
    }
}

struct Test : Decodable {
    var disease: String?
    var type: String?
    var name: String?
    var manufacturer: String?
    var sampleOrigin: String?
    var timeStampSample: String?
    var timeStampResult: String?
    var result: String?
    var facility: String?
    var facilityAddress: String?
    var healthprofessionaIdentification: String?
    var country: String?
    
    init?(from cbor: CBOR?) {
        guard let cbor = cbor else {
            return nil
        }
        disease = cbor["dis"]?.unwrap() as? String
        type = cbor["typ"]?.unwrap() as? String
        name = cbor["tna"]?.unwrap() as? String
        manufacturer = cbor["tma"]?.unwrap() as? String
        sampleOrigin = cbor["ori"]?.unwrap() as? String
        timeStampSample = cbor["dat"]?.unwrap() as? String
        result = cbor["res"]?.unwrap() as? String
        facility = cbor["fac"]?.unwrap() as? String
    }
}


extension ValidationCore {
    func decodePayload(from object: NSObject) -> VaccinationData? {
        guard let payload = object.cborBytes,
              let decodedPayload = try? CBORDecoder(input: payload).decodeItem() else {
            DDLogError("Cannot decode COSE payload.")
            return nil
        }
        
        return VaccinationData(from: decodedPayload)
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
}
