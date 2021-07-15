//
//  ValueSetContainer.swift
//  
//
//  Created by Dominik Mocher on 19.07.21.
//

import Foundation
import SwiftCBOR

public struct ValueSetContainer {
    let valueSets : [ValueSet]
    
    init?(from cbor: CBOR) {
        guard let transformedValue = cbor["v"]?.asList()?.compactMap({ entry in
            ValueSet(from: entry)
        }) else {
            return nil
        }
        valueSets = transformedValue
    }
}

public struct ValueSet {
    let name : String
    let value : String
    
    enum Key : String {
        case name = "n"
        case value = "v"
    }
    
    init?(from cbor: CBOR){
        guard let cborMap = cbor.asMap(),
              let name = cborMap[Key.name]?.asString(),
              let value = cborMap[Key.value]?.asString() else {
            return nil
        }
        self.name = name
        self.value = value
    }
}
