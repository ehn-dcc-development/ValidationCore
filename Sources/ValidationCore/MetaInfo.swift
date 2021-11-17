//
//  MetaInfo.swift
//  
//
//  Created by Dominik Mocher on 08.06.21.
//

import Foundation

public struct MetaInfo : Codable {
    public let expirationTime : String?
    public let issuedAt : String?
    public let issuer : String?
    public let notBefore : String?
    public let dgcErrors : [ValidationError]?
    public let signatureCertInfo: SignatureCertInfo?
    public let trustlistInfo: TrustlistInfo?
    
    init(from cwt: CWT?, signatureCertInfo: SignatureCertInfo? = nil, trustlistInfo: TrustlistInfo? = nil, errors : [ValidationError]? = nil) {
        self.expirationTime = cwt?.exp?.toIso8601DateString()
        self.issuedAt = cwt?.iat?.toIso8601DateString()
        self.issuer = cwt?.iss
        self.notBefore = cwt?.nbf?.toIso8601DateString()
        self.dgcErrors = errors
        self.signatureCertInfo = signatureCertInfo
        self.trustlistInfo = trustlistInfo
    }
}
