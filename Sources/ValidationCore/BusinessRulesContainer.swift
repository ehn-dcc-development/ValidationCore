//
//  BusinessRulesContainer.swift
//  
//
//  Created by Dominik Mocher on 19.07.21.
//

import Foundation
import SwiftCBOR

public struct BusinessRulesContainer : SignedData, Codable {
    public var hash: Data?
    public var isEmpty: Bool {
        return rules.isEmpty
    }
    
    public let rules : [BusinessRule]
    
    enum CodingKeys: String, CodingKey {
        case rules = "r"
        case hash = "signatureHash"
    }
    
    public init() {
        rules = [BusinessRule]()
    }
    
    init?(from cbor: CBOR) {
        guard let transformedRules = cbor["r"]?.asList()?.compactMap({ entry in
            BusinessRule(from: entry)
        }) else {
            return nil
        }
        rules = transformedRules
    }
}

public struct BusinessRule : Codable {
    public let identifier : String
    public let rule : String
    
    enum CodingKeys : String, CodingKey {
        case identifier = "i"
        case rule = "r"
    }
    
    init?(from cbor: CBOR) {
        guard let cborMap = cbor.asMap(),
              let identifier = cborMap[CodingKeys.identifier]?.asString(),
              let rule = cborMap[CodingKeys.rule]?.asString() else {
            return nil
        }
        self.identifier = identifier
        self.rule = rule
    }
}

