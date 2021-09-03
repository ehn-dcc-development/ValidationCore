//
//  SignatureInfo.swift
//  
//
//  Created by Dominik Mocher on 19.07.21.
//

import Foundation

public struct SignatureInfo {
    public let validFrom: Date
    public let validUntil : Date
    public let content: Data
}
