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
    let payload : CBOR
    let signature : Data
    
    var keyId : Data? {
        get {
            var keyData : Data?
            if let unprotectedKeyId = unprotectedHeader?.keyId {
                keyData = Data(unprotectedKeyId)
            }
            if let protectedKeyId = protectedHeader.keyId {
                keyData = Data(protectedKeyId)
            }
            return keyData
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
                let cborArray = CBOR(arrayLiteral: context, header, externalAad, payload)
                return Data(cborArray.encode())
            default:
                DDLogError("COSE Sign messages are not yet supported.")
                return nil
            }
        }
    }
    
    init?(from data: Data) {
        let cborType = CborType.from(data: data)
        switch cborType {
        case .tag:
            guard let cose = try? CBOR.decode(data.bytes)?.asCose(),
                  let protectedHeader = CoseHeader(fromBytestring: cose.1[0]),
                  let signature = cose.1[3].asBytes(),
                  let type = CoseType.from(data: data) else {
                return nil
            }
            self.type = type
            self.protectedHeader = protectedHeader
            self.unprotectedHeader = CoseHeader(from: cose.1[1])
            self.payload = cose.1[2]
            self.signature = Data(signature)
        case .list:
            guard let coseData = try? CBOR.decode(data.bytes),
                  let coseList = coseData.asList(),
                  let protectedHeader = CoseHeader(fromBytestring: coseList[0]),
                  let signature = coseList[3].asBytes() else {
                return nil
            }
            self.protectedHeader = protectedHeader
            self.unprotectedHeader = CoseHeader(fromBytestring: coseList[1]) ?? nil
            self.payload = coseList[2]
            self.signature = Data(signature)
            self.type = .sign1
        case .cwt:
            guard let rawCose = try? CBORDecoder(input: data.bytes).decodeItem(),
                  let cwtCose = rawCose.unwrap() as? (CBOR.Tag, CBOR),
                  let coseData = cwtCose.1.unwrap() as? (CBOR.Tag, CBOR),
                  let coseList = coseData.1.asList(),
                  let protectedHeader = CoseHeader(fromBytestring: coseList[0]),
                  let signature = coseList[3].asBytes() else {
                return nil
            }
            self.protectedHeader = protectedHeader
            self.unprotectedHeader = CoseHeader(fromBytestring: coseList[1]) ?? nil
            self.payload = coseList[2]
            self.signature = Data(signature)
            self.type = .sign1
        case .unknown:
            DDLogError("Unknown CBOR type.")
            return nil
        }
    }
    
    func hasValidSignature(for publicKey: SecKey) -> Bool {
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
        default:
            DDLogError("Verification algorithm not supported.")
            return false
        }
        
        var error : Unmanaged<CFError>?
        let result = SecKeyVerifySignature(key, algorithm, signedData as CFData, signature as CFData, &error)
        if let error = error {
            DDLogError("Signature verification error: \(error)")
        }
        return result
    }
    
    // MARK: - Nested Types
    
    struct CoseHeader {
        fileprivate let rawHeader : CBOR?
        let keyId : [UInt8]?
        let algorithm : Algorithm?
        
        enum Headers : Int {
            case keyId = 4
            case algorithm = 1
        }
        
        enum Algorithm : UInt64 {
            case es256 = 6 //-7
            case ps256 = 36 //-37
        }
        
        init?(fromBytestring cbor: CBOR){
            guard let cborMap = cbor.decodeBytestring()?.asMap(),
                  let algValue = cborMap[Headers.algorithm]?.asUInt64(),
                  let alg = Algorithm(rawValue: algValue) else {
                return nil
            }
            self.init(alg: alg, keyId: cborMap[Headers.keyId]?.asBytes(), rawHeader: cbor)
        }
        
        init?(from cbor: CBOR) {
            let cborMap = cbor.asMap()
            var alg : Algorithm?
            if let algValue = cborMap?[Headers.algorithm]?.asUInt64() {
                alg = Algorithm(rawValue: algValue)
            }
            self.init(alg: alg, keyId: cborMap?[Headers.keyId]?.asBytes())
        }
        
        private init(alg: Algorithm?, keyId: [UInt8]?, rawHeader : CBOR? = nil){
            self.algorithm = alg
            self.keyId = keyId
            self.rawHeader = rawHeader
        }
    }
    
    enum CoseType : String {
        case sign1 = "Signature1"
        case sign = "Signature"
        
        static func from(data: Data) -> CoseType? {
            guard let cose = try? CBORDecoder(input: data.bytes).decodeItem()?.asCose() else {
                return nil
            }
            switch cose.0 {
            case .coseSign1Item: return .sign1
            case .coseSignItem: return .sign
            default:
                return nil
            }
        }
    }
}

