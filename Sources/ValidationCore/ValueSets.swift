//
//  ValueSets.swift
//  
//
//  Created by Martin Fitzka-Reichart on 14.07.21.
//

import Foundation

struct ValueSetContainer: SignedData, Codable {
    let entries : [ValueSetEntry]

    var hash: Data?

    enum CodingKeys: String, CodingKey {
        case entries = "v"
        case hash = "signatureHash"
    }

    init() {
        entries = [ValueSetEntry]()
    }

    var isEmpty: Bool {
        return entries.isEmpty
    }
}

struct ValueSetEntry: Codable {
    let name: String
    let valueSet: String

    enum CodingKeys: String, CodingKey {
        case name = "n"
        case valueSet = "v"
    }
}
