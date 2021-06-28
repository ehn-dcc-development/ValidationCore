//
//  File.swift
//  
//
//  Created by Dominik Mocher on 17.06.21.
//

import Foundation
import Security


public class X509TrustlistService : TrustlistService {
    let signingCertificates : [TrustEntry]
    let dateService : DateService
    let areValidityChecksEnabled : Bool
    
    public init(base64Encoded signingCertificates: [Data: String], dateService : DateService? = nil, enableValidityChecks: Bool = true) {
        self.dateService = dateService ?? DefaultDateService()
        self.areValidityChecksEnabled = enableValidityChecks
        self.signingCertificates = signingCertificates.compactMap { (keyId, certString) in
            guard let certData = Data(base64Encoded: certString) else {
                return nil
            }
            return TrustEntry(cert: certData, keyId: keyId)
        }
    }
    
    public func key(for keyId: Data, keyType: CertType, completionHandler: @escaping (Result<SecKey, ValidationError>) -> ()) {
        guard let trustEntry = signingCertificates.first(where: { entry in keyId == entry.keyId }) else {
            completionHandler(.failure(.KEY_NOT_IN_TRUST_LIST))
            return
        }
        
        if areValidityChecksEnabled {
            guard trustEntry.isSuitable(for: keyType) else {
                completionHandler(.failure(.UNSUITABLE_PUBLIC_KEY_TYPE))
                return
            }
            guard trustEntry.isValid(for: dateService) else {
                completionHandler(.failure(.PUBLIC_KEY_EXPIRED))
                return
            }
        }
        guard let secKey = trustEntry.publicKey else {
            completionHandler(.failure(.KEY_CREATION_ERROR))
            return
        }
        completionHandler(.success(secKey))
    }
    
    public func key(for keyId: Data, cwt: CWT, keyType: CertType, completionHandler: @escaping (Result<SecKey, ValidationError>) -> ()) {
        self.key(for: keyId, keyType: keyType, completionHandler: completionHandler)
    }
    
    public func updateTrustlistIfNecessary(completionHandler: @escaping (ValidationError?) -> ()) {
        /* not used */
    }
}
