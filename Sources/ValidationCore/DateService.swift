//
//  DateService.swift
//  
//
//  Created by Dominik Mocher on 12.05.21.
//

import Foundation

public protocol DateService {
    func isNowAfter(_ date: Date) -> Bool
    func isNowBefore(_ date: Date) -> Bool
}

struct DefaultDateService : DateService {
    func isNowAfter(_ date: Date) -> Bool {
        let now = Date()
        return now.isAfter(date)
    }
    
    func isNowBefore(_ date: Date) -> Bool {
        let now = Date()
        return now.isBefore(date)
    }
}
