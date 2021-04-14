//
//  Extensions.swift
//  
//
//  Created by Dominik Mocher on 14.04.21.
//

import Foundation

extension Data{
 func humanReadable() -> String {
    return self.map { String(format: "%02x ", $0) }.joined()
 }
}

extension Data {
    public var bytes : [UInt8] {
        return [UInt8](self)
    }
}
