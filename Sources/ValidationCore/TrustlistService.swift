//
//  File.swift
//  
//
//  Created by Dominik Mocher on 26.04.21.
//

import Foundation
import SwiftCBOR
import CocoaLumberjackSwift
import Security

public protocol TrustlistService {
    func key(for keyId: Data, keyType: CertType, completionHandler: @escaping (Result<SecKey, ValidationError>)->())
    func key(for keyId: Data, cwt: CWT, keyType: CertType, completionHandler: @escaping (Result<SecKey, ValidationError>)->())
    func updateTrustlistIfNecessary(completionHandler: @escaping (ValidationError?)->())
    func debugInformation(for keyId: Data, certType: CertType?, cwt: CWT?) -> TrustlistDebugInfo
}

extension TrustlistService {
    public func updateTrustlistIfNecessary(completionHandler: @escaping (ValidationError?)->()) {}
    
    public func debugInformation(for keyId: Data, certType: CertType?, cwt: CWT?) -> TrustlistDebugInfo {
        return TrustlistDebugInfo(signatureCertInfo: nil, trustlistExpiration: Date(timeIntervalSince1970: 0), trustlistDownloadedAt: Date(timeIntervalSince1970: 0), trustlistUrl: "", trustlistEntries: 0, errors: nil)
    }
}
