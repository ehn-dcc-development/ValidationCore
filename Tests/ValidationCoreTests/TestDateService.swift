//
//  TestDateService.swift
//  
//
//  Created by Dominik Mocher on 12.05.21.
//

import Foundation
import ValidationCore

struct TestDateService : DateService {
    let now : Date?
    
    init(_ testData: EuTestData) {
        now = testData.expectedResults.isExpired == false ? testData.testContext.validationClock : nil
    }
    
    func isNowAfter(_ date: Date) -> Bool {
        return now?.isAfter(date) ?? true
    }
    
    func isNowBefore(_ date: Date) -> Bool {
        return now?.isBefore(date) ?? true
    }
}
