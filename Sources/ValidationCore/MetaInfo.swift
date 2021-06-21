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
    
    init(from cwt: CWT) {
        expirationTime = cwt.exp?.toIso8601DateString()
        issuedAt = cwt.iat?.toIso8601DateString()
        issuer = cwt.iss
        notBefore = cwt.nbf?.toIso8601DateString()
    }
}
