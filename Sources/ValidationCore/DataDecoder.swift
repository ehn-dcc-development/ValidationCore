//
//  DataDecoder.swift
//  
//
//  Created by Dominik Mocher on 15.07.21.
//

import Foundation
import SwiftCBOR

public struct DataDecoder {
    public init() {}
    
    public func decode(signatureCose: Data, trustAnchor: String, dateService: DateService) throws -> SignatureInfo {
        guard let cose = Cose(from: signatureCose),
              let trustAnchorKey = key(from: trustAnchor.normalizeCertificate()),
              cose.hasValidSignature(for: trustAnchorKey) else {
            throw ValidationError.TRUST_LIST_SIGNATURE_INVALID
        }
        guard let cwt = CWT(from: cose.payload),
              let subject = cwt.sub else {
            throw ValidationError.TRUST_SERVICE_ERROR
        }
        guard cwt.isAlreadyValid(using: dateService) else {
            throw ValidationError.TRUST_LIST_NOT_YET_VALID
        }
        
        guard cwt.isNotExpired(using: dateService) else {
            throw ValidationError.TRUST_LIST_EXPIRED
        }
        
        guard let validFrom = cwt.notBefore ?? cwt.issuedAt,
              let validUntil = cwt.expiresAt ?? cwt.expiresAt else {
            throw ValidationError.TRUST_SERVICE_ERROR
        }

        return SignatureInfo(validFrom: validFrom, validUntil: validUntil, content: subject)
    }
    
    public func decode(businessRules: Data, signature: Data, trustAnchor: String, dateService: DateService? = nil) throws -> (SignatureInfo, BusinessRulesContainer) {
        let signatureInfo = try decode(signatureCose: signature, trustAnchor: trustAnchor, dateService: dateService ?? DefaultDateService())
        let decodedRules = try decode(map: businessRules)
        guard let rules = BusinessRulesContainer(from: decodedRules) else {
            throw ValidationError.TRUST_SERVICE_ERROR
        }
        return (signatureInfo, rules)
    }
    
    public func decode(valueSets: Data, signature: Data, trustAnchor: String, dateService: DateService? = nil) throws -> (SignatureInfo, ValueSetContainer) {
        let signatureInfo = try decode(signatureCose: signature, trustAnchor: trustAnchor, dateService: dateService ?? DefaultDateService())
        let decodedValueSets = try decode(map: valueSets)
        guard let sets = ValueSetContainer(from: decodedValueSets) else {
            throw ValidationError.TRUST_SERVICE_ERROR
        }
        return (signatureInfo, sets)
    }
    
    private func key(from trustAnchor: String) -> SecKey? {
        guard let certData = Data(base64Encoded: trustAnchor),
              let certificate = SecCertificateCreateWithData(nil, certData as CFData),
              let secKey = SecCertificateCopyKey(certificate) else {
            return nil
        }
        return secKey
    }
    
    private func decode(map: Data) throws -> CBOR {
        guard let byteString = try CBOR.decode(map.encode()),
              let decoded = byteString.decodeBytestring() else {
            throw ValidationError.TRUST_SERVICE_ERROR
        }
        return decoded
    }
}
