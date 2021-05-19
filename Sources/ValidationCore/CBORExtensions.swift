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
        case .tagged(let tag, let cbor): return (tag, cbor)
        case .array(let array): return array
        case .map(let map): return map
        case .utf8String(let value): return value
        case .negativeInt(let value): return value
        case .unsignedInt(let value): return value
        default:
            return nil
        }
    }
    
    func asUInt64() -> UInt64? {
        return self.unwrap() as? UInt64
    }
    
    func asInt64() -> Int64? {
        return self.unwrap() as? Int64
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
    
    func asData() -> Data {
        return Data(self.encode())
    }
     
    func asCose() -> (CBOR.Tag, [CBOR])? {
        guard let rawCose =  self.unwrap() as? (CBOR.Tag, CBOR),
              let cosePayload = rawCose.1.asList() else {
            return nil
        }
        return (rawCose.0, cosePayload)
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
    public static let coseSignItem = CBOR.Tag(rawValue: 98)
}


extension Dictionary where Key == CBOR {
    subscript<Index: RawRepresentable>(index: Index) -> Value? where Index.RawValue == String {
        return self[CBOR(stringLiteral: index.rawValue)]
    }
    
    subscript<Index: RawRepresentable>(index: Index) -> Value? where Index.RawValue == Int {
        return self[CBOR(integerLiteral: index.rawValue)]
    }
}

enum CborType: UInt8 {
    case tag = 210
    case list = 132
    case cwt = 216
    case unknown
    
    static func from(data: Data) -> CborType {
        switch data.bytes[0] {
        case self.tag.rawValue: return tag
        case list.rawValue: return list
        case cwt.rawValue: return cwt
        default: return unknown
        }
    }
}
