//
//  SignatureInfo.swift
//  
//
//  Created by Dominik Mocher on 19.07.21.
//

import Foundation

public struct SignatureInfo {
    let validFrom: Date
    let validUntil : Date
    let content: Data
}
