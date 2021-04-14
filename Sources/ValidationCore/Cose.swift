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
            let externalAad = CBOR.byteString([UInt8]()) /*no external application specific data*/
            let cborArray = CBOR(arrayLiteral: context, header.rawHeader, externalAad, payload.rawPayload)
            return Data(cborArray.encode())
        }
    }
    
    init?(from data: Data) {
        guard let cose = try? CBORDecoder(input: data.bytes).decodeItem()?.asCose(),
              let header = CoseHeader(from: cose[0]),
              let payload = CWT(from: cose[2]),
              let signature = cose[3].asBytes() else {
            return nil
        }
        self.header = header
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
 
        /* Only supporting ES256 signatures and Sign1 messages for the moment */
        return hasCoseSign1ValidSignature(for: publicKey)
   }
    
    private func hasCoseSign1ValidSignature(for key: SecKey) -> Bool {
        guard let signedData = signatureStruct else {
            DDLogError("Cannot create Sign1 structure.")
            return false
        }
        return verifySignature(key: key, signedData: signedData, rawSignature: signature)
    }
    
    private func verifySignature(key: SecKey, signedData : Data, rawSignature : Data, algorithm : SecKeyAlgorithm = .ecdsaSignatureMessageX962SHA256) -> Bool {
        let asn1Signature = Asn1Encoder().convertRawSignatureIntoAsn1(signature)
        var error : Unmanaged<CFError>?
        let result = SecKeyVerifySignature(key, .ecdsaSignatureMessageX962SHA256, signedData as CFData, asn1Signature as CFData, &error)
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
        case hcert = 99
        
        enum HcertKeys : Int {
            case euHealthCertV1 = 1
        }
    }

    init?(from cbor: CBOR) {
        guard let decodedPayload = cbor.decodeBytestring() else {
           return nil
        }
        rawPayload = cbor
        iss = decodedPayload[PayloadKeys.iss.toCbor()]?.asString()
        exp = decodedPayload[PayloadKeys.exp.toCbor()]?.asUInt64()
        iat = decodedPayload[PayloadKeys.iat.toCbor()]?.asUInt64()
        guard let hCertMap = decodedPayload[PayloadKeys.hcert.toCbor()]?.asMap(),
              let certData = hCertMap[PayloadKeys.HcertKeys.euHealthCertV1.toCbor()]?.decodeBytestring() else {
            return nil
        }
        
        euHealthCert = EuHealthCert(from: certData)
    }
}

struct CoseHeader {
    fileprivate let rawHeader : CBOR
    let keyId : String
    let algorithm : UInt64

    enum Headers : Int {
        case keyId = 4
        case algorithm = 1
    }

    init?(from cbor: CBOR){
        guard let decodedBytestring = cbor.decodeBytestring(),
             let keyId = decodedBytestring[Headers.keyId.toCbor()]?.asString(),
             let alg = decodedBytestring[Headers.algorithm.toCbor()]?.asUInt64() else {
            return nil
        }
        rawHeader = cbor
        self.keyId = keyId
        self.algorithm = alg
    }
}




extension Data {
    public var bytes : [UInt8] {
        return [UInt8](self)
    }
}

extension RawRepresentable where RawValue == Int {
    fileprivate func toCbor() ->  CBOR {
        return CBOR(integerLiteral: self.rawValue)
    }
}
