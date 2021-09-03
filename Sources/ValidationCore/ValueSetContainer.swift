//
//  ValueSetContainer.swift
//  
//
//  Created by Dominik Mocher on 19.07.21.
//

import Foundation
import SwiftCBOR

public struct ValueSetContainer : SignedData, Codable {
    public let valueSets : [ValueSet]
    public var hash: Data?
    
    enum CodingKeys: String, CodingKey {
        case valueSets = "v"
        case hash = "signatureHash"
    }
    
    public init() {
        valueSets = [ValueSet]()
    }
    
    init?(from cbor: CBOR) {
        guard let transformedValue = cbor["v"]?.asList()?.compactMap({ entry in
            ValueSet(from: entry)
        }) else {
            return nil
        }
        valueSets = transformedValue
    }
    
    public var isEmpty: Bool {
        return valueSets.isEmpty
    }
}

public struct ValueSet : Codable {
    public let name : String
    public let value : String
    
    enum CodingKeys : String, CodingKey {
        case name = "n"
        case value = "v"
    }
    
    init?(from cbor: CBOR){
        guard let cborMap = cbor.asMap(),
              let name = cborMap[CodingKeys.name]?.asString(),
              let value = cborMap[CodingKeys.value]?.asString() else {
            return nil
        }
        self.name = name
        self.value = value
    }
}
