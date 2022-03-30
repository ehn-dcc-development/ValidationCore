//
//  Extensions.swift
//  
//
//  Created by Dominik Mocher on 14.04.21.
//

import Foundation

extension Data {
    func asHex(useSpaces: Bool = true) -> String {
        return self.map { String(format: "%02x\(useSpaces ? " " : "")", $0) }.joined()
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

public extension Date {
    func isBefore(_ date: Date) -> Bool {
        if #available(iOS 13.0, *) {
            return distance(to: date) > 0
        } else {
            return self < date
        }
    }
    func isAfter(_ date: Date) -> Bool {
        if #available(iOS 13.0, *) {
            return distance(to: date) < 0
        } else {
            return self > date
        }
    }
}

extension Int {
    var hour : Int {
        return self.minutes * 60
    }
    
    var minutes : Int {
        return self * 60
    }
}

extension Double {
    func toUInt64() -> UInt64 {
        return UInt64(self)
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
    
    func isMinimalVersion(major: Int, minor: Int) -> Bool {
        let version = self.split(separator: ".")
        guard version.count > 2,
              let majorVersion = Int(version[0]),
              let minorVersion = Int(version[1]) else {
            return false
        }
        return majorVersion >= major && minorVersion >= minor
    }
    
    func normalizeCertificate() -> String {
        return self.replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "CERTIFICATE", with: "")
            .replacingOccurrences(of: "BEGIN", with: "")
            .replacingOccurrences(of: "END", with: "")
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "\n", with: "")
    }
}

extension UInt64 {
    func toDate() -> Date? {
        return Date(timeIntervalSince1970: TimeInterval(self))
    }
    
    func toIso8601DateString() -> String? {
        guard let date = self.toDate() else {
            return nil
        }
        return ISO8601DateFormatter().string(from: date)
    }
}

extension Optional where Wrapped : Collection {
    var oneOrMore : Bool {
        guard let this = self else {
            return false
        }
        return this.count >= 1
    }
    
    var exactlyOne : Bool {
        guard let this = self else {
            return false
        }
        return this.count == 1
    }
}


