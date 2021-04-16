//
//  Cose.swift
//  
//
//  Created by Dominik Mocher on 07.04.21.
//

import Foundation
import SwiftCBOR
import CocoaLumberjackSwift
import Security

struct Cose {
    private let type: CoseType
    let protectedHeader : CoseHeader
    let unprotectedHeader : CoseHeader?
    let payload : CWT
    let signature : Data
    
    enum CoseType : String {
        case sign1 = "Signature1"
        case sign = "Signature"
        
        static func from(tag: CBOR.Tag) -> CoseType? {
            switch tag {
            case .coseSign1Item: return .sign1
            case .coseSignItem: return .sign
            default:
                return nil
            }
        }
    }

    private var signatureStruct : Data? {
        get {
            guard let header = protectedHeader.rawHeader else {
                return nil
            }
            
            /* Structure according to https://tools.ietf.org/html/rfc8152#section-4.2 */
            switch type {
            case .sign1:
                let context = CBOR(stringLiteral: self.type.rawValue)
                let externalAad = CBOR.byteString([UInt8]()) /*no external application specific data*/
                let cborArray = CBOR(arrayLiteral: context, header, externalAad, payload.rawPayload)
                return Data(cborArray.encode())
            default:
                DDLogError("COSE Sign messages are not yet supported.")
                return nil
                
            }

        }
    }
    
    init?(from data: Data) {
        guard let cose = try? CBORDecoder(input: data.bytes).decodeItem()?.asCose(),
              let type = CoseType.from(tag: cose.0),
              let protectedHeader = CoseHeader(fromBytestring: cose.1[0]),
              let payload = CWT(from: cose.1[2]),
              let signature = cose.1[3].asBytes() else {
            return nil
        }
        self.type = type
        self.protectedHeader = protectedHeader
        self.unprotectedHeader = CoseHeader(from: cose.1[1])
        self.payload = payload
        self.signature = Data(signature)
    }

    func hasValidSignature(for encodedCert: String?) -> Bool {
        guard let encodedCert = encodedCert else {
            DDLogError("No certificate, assuming COSE is not valid.")
            return false
        }
        guard let encodedCertData = Data(base64Encoded: encodedCert),
              let cert = SecCertificateCreateWithData(nil, encodedCertData as CFData),
              let publicKey = SecCertificateCopyKey(cert) else {
            DDLogError("Cannot decode certificate.")
            return false
        }
 
        /* Only supporting Sign1 messages for the moment */
        switch type {
        case .sign1:
            return hasCoseSign1ValidSignature(for: publicKey)
        default:
            DDLogError("COSE Sign messages are not yet supported.")
            return false
        }
   }
    
    private func hasCoseSign1ValidSignature(for key: SecKey) -> Bool {
        guard let signedData = signatureStruct else {
            DDLogError("Cannot create Sign1 structure.")
            return false
        }
        

        return verifySignature(key: key, signedData: signedData, rawSignature: signature)
    }
    
    private func verifySignature(key: SecKey, signedData : Data, rawSignature : Data) -> Bool {
        var algorithm : SecKeyAlgorithm
        var signature = rawSignature
        switch protectedHeader.algorithm {
        case .es256:
            algorithm = .ecdsaSignatureMessageX962SHA256
            signature = Asn1Encoder().convertRawSignatureIntoAsn1(rawSignature)
        case .ps256:
            algorithm = .rsaSignatureMessagePSSSHA256
        }
 
        var error : Unmanaged<CFError>?
        let result = SecKeyVerifySignature(key, algorithm, signedData as CFData, signature as CFData, &error)
        if let error = error {
            DDLogError("Signature verification error: \(error)")
        }
        return result
    }
}

struct CWT {
    fileprivate let rawPayload : CBOR
    let iss : String?
    let exp : UInt64?
    let iat : UInt64?
    let euHealthCert : EuHealthCert
    
    enum PayloadKeys : Int {
        case iss = 1
        case iat = 6
        case exp = 4
        case hcert = -260
        
        enum HcertKeys : Int {
            case euHealthCertV1 = 1
        }
    }

    init?(from cbor: CBOR) {
        guard let decodedPayload = cbor.decodeBytestring()?.asMap() else {
           return nil
        }
        rawPayload = cbor
        iss = decodedPayload[PayloadKeys.iss]?.asString()
        exp = decodedPayload[PayloadKeys.exp]?.asUInt64()
        iat = decodedPayload[PayloadKeys.iat]?.asUInt64()
        guard let hCertMap = decodedPayload[PayloadKeys.hcert]?.asMap(),
              let certData = hCertMap[PayloadKeys.HcertKeys.euHealthCertV1]?.decodeBytestring() else {
            return nil
        }
        
        euHealthCert = EuHealthCert(from: certData)
    }
}

struct CoseHeader {
    fileprivate let rawHeader : CBOR?
    let keyId : String
    let algorithm : Algorithm

    enum Headers : Int {
        case keyId = 4
        case algorithm = 1
    }
    
    enum Algorithm : UInt64 {
        case es256 = 6 //TODO should be -7
        case ps256 = 36
    }

    init?(fromBytestring cbor: CBOR){
        guard let cborMap = cbor.decodeBytestring()?.asMap(),
              let keyId = cborMap[Headers.keyId]?.asString(),
              let algValue = cborMap[Headers.algorithm]?.asUInt64(), //TODO should be deserialized to negative Int
              let alg = Algorithm(rawValue: algValue) else {
            return nil
        }
        self.init(alg: alg, keyId: keyId, rawHeader: cbor)
    }
    
    init?(from cbor: CBOR) {
        guard let cborMap = cbor.asMap(),
             let keyId = cborMap[Headers.keyId]?.asString(),
             let algValue = cborMap[Headers.algorithm]?.asUInt64(), //TODO should be deserialized to negative Int
             let alg = Algorithm(rawValue: algValue) else {
            return nil
        }
        self.init(alg: alg, keyId: keyId)
    }
    
    private init(alg: Algorithm, keyId: String, rawHeader : CBOR? = nil){
        self.algorithm = alg
        self.keyId = keyId
        self.rawHeader = rawHeader
    }
}
