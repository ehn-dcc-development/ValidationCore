//
//  MetaInfo.swift
//  
//
//  Created by Dominik Mocher on 08.06.21.
//

import Foundation

public struct MetaInfo : Codable {
    let expirationTime : String?
    let issuedAt : String?
    let issuer : String?
    
    init(from cwt: CWT) {
        expirationTime = cwt.exp?.toIso8601DateString()
        issuedAt = cwt.iat?.toIso8601DateString()
        issuer = cwt.iss
    }
}
