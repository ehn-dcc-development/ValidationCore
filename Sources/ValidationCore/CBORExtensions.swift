//
//  CBORExtensions.swift
//  
//
//  Created by Dominik Mocher on 14.04.21.
//

import Foundation
import SwiftCBOR

extension CBOR {
    func unwrap() -> Any? {
        switch self {
        case .simple(let value): return value
        case .boolean(let value): return value
        case .byteString(let value): return value
        case .date(let value): return value
        case .double(let value): return value
        case .float(let value): return value
        case .half(let value): return value
        case .tagged(let tag, let cbor): return cbor
        case .array(let array): return array
        case .map(let map): return map
        case .utf8String(let value): return value
        case .unsignedInt(let value): return value
        case .negativeInt(let value): return value
        default:
            return nil
        }
    }
    
    func asUInt64() -> UInt64? {
        return self.unwrap() as? UInt64
    }
    
    func asString() -> String? {
        return self.unwrap() as? String
    }
    
    func asList() -> [CBOR]? {
        return self.unwrap() as? [CBOR]
    }
    
    func asMap() -> [CBOR:CBOR]? {
        return self.unwrap() as? [CBOR:CBOR]
    }
    
    func asBytes() -> [UInt8]? {
        return self.unwrap() as? [UInt8]
    }
    
    func asCose() -> [CBOR]? {
        guard let rawCose =  self.unwrap() as? CBOR,
              let cose = rawCose.asList() else {
            return nil
        }
        return cose
    }
    
    func decodeBytestring() -> CBOR? {
        guard let bytestring = self.asBytes(),
              let decoded = try? CBORDecoder(input: bytestring).decodeItem() else {
            return nil
        }
        return decoded
    }
    
}

extension CBOR.Tag {
    public static let coseSign1Item = CBOR.Tag(rawValue: 18)
}


extension Dictionary where Key == CBOR {
    subscript<Index: RawRepresentable>(index: Index) -> Value? where Index.RawValue == String {
        return self[CBOR(stringLiteral: index.rawValue)]
    }
    
    subscript<Index: RawRepresentable>(index: Index) -> Value? where Index.RawValue == Int {
        return self[CBOR(integerLiteral: index.rawValue)]
    }
}
