//
//  TestTrustlistService.swift
//  
//
//  Created by Dominik Mocher on 07.05.21.
//

import Foundation
import ValidationCore

class TestTrustlistService {
    let validationTime : Date?
    let encodedCert : String?
    
    init(_ testContext: TestContext){
        validationTime = testContext.validationClock
        encodedCert = testContext.signingCertificate
    }
}

extension TestTrustlistService: TrustlistService {
    func key(for keyId: Data, keyType: CertType, completionHandler: @escaping (Result<SecKey, ValidationError>) -> ()) {
        guard let base64Cert = encodedCert,
              let certData = Data(base64Encoded: base64Cert),
              let certificate = SecCertificateCreateWithData(nil, certData as CFData),
              let secKey = SecCertificateCopyKey(certificate) else {
            completionHandler(.failure(.KEY_CREATION_ERROR))
            return
        }
        completionHandler(.success(secKey))
    }
    
    func updateTrustlist(completionHandler: @escaping (ValidationError?) -> ()) {
        /* not implemented */
    }
}
