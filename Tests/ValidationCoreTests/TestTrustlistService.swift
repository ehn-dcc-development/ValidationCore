//
//  TestTrustlistService.swift
//  
//
//  Created by Dominik Mocher on 07.05.21.
//

import Foundation
import ValidationCore

class TestTrustlistService {
    let dateService : DateService
    let encodedCert : String?
    let testData : EuTestData
    
    init(_ testData: EuTestData, dateService: DateService){
        self.dateService = dateService
        self.testData = testData
        encodedCert = testData.testContext.signingCertificate
    }
    
}

extension TestTrustlistService: TrustlistService {
    func key(for keyId: Data, cwt: CWT, keyType: CertType, completionHandler: @escaping (Result<SecKey, ValidationError>) -> ()) {
        return key(for: keyId, keyType: keyType, completionHandler: completionHandler)
    }

    func key(for keyId: Data, keyType: CertType, completionHandler: @escaping (Result<SecKey, ValidationError>) -> ()) {
        guard let encodedCert = encodedCert,
              let cert = Data(base64Encoded: encodedCert) else {
            completionHandler(.failure(.GENERAL_ERROR))
            return
        }
        
        let entry = TrustEntry(cert: cert)
        guard testData.expectedResults.isExpired == nil || entry.isValid(for: dateService) else {
            completionHandler(.failure(.PUBLIC_KEY_EXPIRED))
            return
        }
        guard entry.isSuitable(for: keyType) else {
            completionHandler(.failure(.UNSUITABLE_PUBLIC_KEY_TYPE))
            return
        }
        guard let secKey = entry.publicKey else {
            completionHandler(.failure(.KEY_CREATION_ERROR))
            return
        }
        completionHandler(.success(secKey))
    }
    
    func updateTrustlistIfNecessary(completionHandler: @escaping (ValidationError?) -> ()) {
        /* not implemented */
    }
}
