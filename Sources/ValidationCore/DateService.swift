//
//  DateService.swift
//  
//
//  Created by Dominik Mocher on 12.05.21.
//

import Foundation

public protocol DateService {
    var now : Date {get}
    func isNowAfter(_ date: Date) -> Bool
    func isNowBefore(_ date: Date) -> Bool
}

public struct DefaultDateService : DateService {
    public init() {}
    
    public var now: Date {
        get {
            return Date()
        }
    }
    
    public func isNowAfter(_ date: Date) -> Bool {
        let now = Date()
        return now.isAfter(date)
    }
    
    public func isNowBefore(_ date: Date) -> Bool {
        let now = Date()
        return now.isBefore(date)
    }
}
