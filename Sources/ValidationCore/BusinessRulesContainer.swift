//
//  BusinessRulesContainer.swift
//  
//
//  Created by Dominik Mocher on 19.07.21.
//

import Foundation
import SwiftCBOR

public struct BusinessRulesContainer {
    let rules : [BusinessRule]
    
    init?(from cbor: CBOR) {
        guard let transformedRules = cbor["r"]?.asList()?.compactMap({ entry in
            BusinessRule(from: entry)
        }) else {
            return nil
        }
        rules = transformedRules
    }
}

public struct BusinessRule {
    let identifier : String
    let rule : String
    
    enum Key : String {
        case identifier = "i"
        case rule = "r"
    }
    
    init?(from cbor: CBOR) {
        guard let cborMap = cbor.asMap(),
             let identifier = cborMap[Key.identifier]?.asString(),
             let rule = cborMap[Key.rule]?.asString() else {
            return nil
        }
        self.identifier = identifier
        self.rule = rule
    }
}

