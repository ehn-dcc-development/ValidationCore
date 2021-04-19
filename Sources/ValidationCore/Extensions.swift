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
    
    public var bytes : [UInt8] {
        return [UInt8](self)
    }
    
    func base64UrlEncodedString() -> String {
        return self.base64EncodedString(options: .endLineWithLineFeed)
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
            .replacingOccurrences(of: "\n", with: "")
    }
}
