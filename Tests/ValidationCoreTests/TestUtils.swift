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
    return Predicate.define("be \(validationError)") { expression, message in
        if let actual = try expression.evaluate(), case validationError = actual {
            return PredicateResult(status: .matches, message: message)
        }
        return PredicateResult(status: .fail, message: message)
    }
}

func beHealthCert(_ healthCert : EuHealthCert?) -> Predicate<EuHealthCert?> {
    return Predicate.define("be \(healthCert)") { expression, message in
        if let actual = try expression.evaluate(), healthCert == actual {
            return PredicateResult(status: .matches, message: message)
        }
        return PredicateResult(status: .fail, message: message)
    }
}

extension EuHealthCert : Equatable {
    public static func == (lhs: EuHealthCert, rhs: EuHealthCert) -> Bool {
        return lhs.version == rhs.version &&
            lhs.person == rhs.person &&
            lhs.dateOfBirth == rhs.dateOfBirth &&
            lhs.recovery == rhs.recovery &&
            lhs.vaccinations == rhs.vaccinations &&
            lhs.tests == rhs.tests
    }
}

extension Person : Equatable {
    public static func == (lhs: Person, rhs: Person) -> Bool {
        return lhs.familyName == rhs.familyName &&
            lhs.givenName == rhs.givenName &&
            lhs.standardizedFamilyName == rhs.standardizedFamilyName &&
            lhs.standardizedGivenName == rhs.standardizedGivenName
    }
}

extension Test : Equatable {
    public static func == (lhs: Test, rhs: Test) -> Bool {
        return lhs.certificateIdentifier == rhs.certificateIdentifier &&
            lhs.certificateIssuer == rhs.certificateIssuer &&
            lhs.country == rhs.country &&
            lhs.disease == rhs.disease &&
            lhs.manufacturer == rhs.manufacturer &&
            lhs.result == rhs.result &&
            lhs.testCenter == rhs.testCenter &&
            lhs.testName == rhs.testName &&
            lhs.timestampResult == rhs.timestampResult &&
            lhs.timestampSample ==  rhs.timestampSample &&
            lhs.type == rhs.type
    }
}

extension Recovery : Equatable {
    public static func == (lhs: Recovery, rhs: Recovery) -> Bool {
        return lhs.certificateIdentifier == rhs.certificateIdentifier &&
            lhs.certificateIssuer == rhs.certificateIssuer &&
            lhs.disease == rhs.disease &&
            lhs.countryOfTest == rhs.countryOfTest &&
            lhs.dateFirstPositiveTest == rhs.dateFirstPositiveTest &&
            lhs.validFrom == rhs.validFrom &&
            lhs.validUntil == rhs.validUntil
    }
}

extension Vaccination : Equatable {
    public static func == (lhs: Vaccination, rhs: Vaccination) -> Bool {
        return lhs.certificateIdentifier == rhs.certificateIdentifier &&
            lhs.certificateIssuer == rhs.certificateIssuer &&
            lhs.country == rhs.country &&
            lhs.disease == rhs.disease &&
            lhs.doseNumber == rhs.doseNumber &&
            lhs.marketingAuthorizationHolder == rhs.marketingAuthorizationHolder &&
            lhs.medicinialProduct == rhs.medicinialProduct &&
            lhs.totalDoses == rhs.totalDoses &&
            lhs.vaccinationDate == rhs.vaccinationDate &&
            lhs.vaccine == rhs.vaccine
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
