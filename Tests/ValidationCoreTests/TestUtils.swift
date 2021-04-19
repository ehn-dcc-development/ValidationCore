//
//  TestUtils.swift
//  
//
//  Created by Dominik Mocher on 19.04.21.
//

import Foundation
import Quick
import Nimble
import ValidationCore

/// Nimble matcher for validation errors
func beError(_ validationError : ValidationError) -> Predicate<ValidationError> {
    return Predicate.define("be error") { expression, message in
        if let actual = try expression.evaluate(), case validationError = actual {
            return PredicateResult(status: .matches, message: message)
        }
        return PredicateResult(status: .fail, message: message)
    }
}
