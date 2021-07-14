//
//  BusinessRules.swift
//  
//
//  Created by Martin Fitzka-Reichart on 14.07.21.
//

import Foundation

struct BusinessRulesContainer: SignedData, Codable {
    let entries : [BusinessRuleEntry]
    var hash: Data?

    enum CodingKeys: String, CodingKey {
        case entries = "r"
        case hash = "signatureHash"
    }

    init() {
        entries = [BusinessRuleEntry]()
    }

    var isEmpty: Bool {
        return entries.isEmpty
    }
}

struct BusinessRuleEntry: Codable {
    let identifier: String
    let rule: String

    enum CodingKeys: String, CodingKey {
        case identifier = "i"
        case rule = "r"
    }
}
