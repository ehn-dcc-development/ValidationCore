//
//  TestDateService.swift
//  
//
//  Created by Dominik Mocher on 12.05.21.
//

import Foundation
import ValidationCore

struct TestDateService : DateService {
    let testNow : Date?
    
    init(_ testData: EuTestData) {
        testNow = testData.expectedResults.isExpired == false ? testData.testContext.validationClock : nil
    }
    
    var now : Date {
        get {
            return testNow ?? Date()
        }
    }
    func isNowAfter(_ date: Date) -> Bool {
        return testNow?.isAfter(date) ?? true
    }
    
    func isNowBefore(_ date: Date) -> Bool {
        return testNow?.isBefore(date) ?? true
    }
}
