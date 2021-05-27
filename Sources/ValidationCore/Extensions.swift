//
//  Extensions.swift
//  
//
//  Created by Dominik Mocher on 14.04.21.
//

import Foundation

extension Data {
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

extension Date {
    func isBefore(_ date: Date) -> Bool {
        return distance(to: date) > 0
    }
    func isAfter(_ date: Date) -> Bool {
        return distance(to: date) < 0
    }
}

extension String {
    func isValidIso8601Date() -> Bool {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = .withFullDate
        return formatter.date(from: self) != nil
    }
    
    func isValidIso8601DateTime() -> Bool {
        let fractionalFormatter = ISO8601DateFormatter()
        fractionalFormatter.formatOptions = .withFractionalSeconds
        return fractionalFormatter.date(from: self) != nil || ISO8601DateFormatter().date(from: self) != nil
    }
    
    func conformsTo(regex: String) -> Bool {
        return self.range(of: regex, options: .regularExpression) != nil
    }
}
