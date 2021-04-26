//
//  EuHealthCert.swift
//  
//
//  Created by Dominik Mocher on 14.04.21.
//

import Foundation
import SwiftCBOR

public struct EuHealthCert : Codable {
    public let person: Person
    public let dateOfBirth : String
    public let version: String
    public let vaccinations: [Vaccination]?
    public let pastInfections: [PastInfection]?
    public let tests: [Test]?

    private enum CodingKeys : String, CodingKey {
        case person = "nam"
        case dateOfBirth = "dob"
        case vaccinations = "v"
        case pastInfections = "r"
        case tests = "t"
        case version = "ver"
    }
 
    init?(from cbor: CBOR) {
       guard let cbor = cbor.asMap(),
              let person = Person(from: cbor[CodingKeys.person]),
              let dateOfBirth = cbor[CodingKeys.dateOfBirth]?.asString(),
              let version = cbor[CodingKeys.version]?.asString() else {
            return nil
        }
              
        self.person = person
        self.dateOfBirth = dateOfBirth
        self.version = version
        vaccinations = (cbor[CodingKeys.vaccinations]?.asList())?.compactMap { Vaccination(from: $0) } ?? nil
        pastInfections = (cbor[CodingKeys.pastInfections]?.asList())?.compactMap { PastInfection(from: $0) } ?? nil
        tests = (cbor[CodingKeys.tests]?.asList())?.compactMap { Test(from: $0) } ?? nil
    }
}

public struct Person : Codable {
    public let givenName: String?
    public let standardizedGivenName: String?
    public let familyName: String?
    public let standardizedFamilyName: String

    private enum CodingKeys : String, CodingKey {
        case givenName = "gn"
        case standardizedGivenName = "gnt"
        case familyName = "fn"
        case standardizedFamilyName = "fnt"
    }
 
    init?(from cbor: CBOR?) {
        guard let cbor = cbor?.asMap(),
              let standardizedFamilyName = cbor[CodingKeys.standardizedFamilyName]?.asString()
              else {
            return nil
        }
        self.standardizedFamilyName = standardizedFamilyName
        givenName = cbor[CodingKeys.givenName]?.asString()
        familyName = cbor[CodingKeys.familyName]?.asString()
        standardizedGivenName = cbor[CodingKeys.standardizedGivenName]?.asString()
    }
}

public struct Vaccination : Codable {
    public let disease: String
    public let vaccine: String
    public let medicinialProduct: String
    public let marketingAuthorizationHolder: String
    public let doseNumber: UInt64
    public let totalDoses: UInt64
    public let vaccinationDate: String
    public let country: String
    public let certificateIssuer: String
    public let certificateIdentifier: String
    
    private enum CodingKeys : String, CodingKey {
           case disease = "tg"
           case vaccine = "vp"
           case medicinialProduct = "mp"
           case marketingAuthorizationHolder = "ma"
           case doseNumber = "dn"
           case totalDoses = "sd"
           case vaccinationDate = "dt"
           case country = "co"
        case certificateIssuer = "is"
        case certificateIdentifier = "ci"
    }
       
    init?(from cbor: CBOR?) {
       guard let cbor = cbor?.asMap(),
         let disease = cbor[CodingKeys.disease]?.asString(),
         let vaccine = cbor[CodingKeys.vaccine]?.asString(),
         let medicinialProduct = cbor[CodingKeys.medicinialProduct]?.asString(),
         let marketingAuthorizationHolder = cbor[CodingKeys.marketingAuthorizationHolder]?.asString(),
         let doseNumber = cbor[CodingKeys.doseNumber]?.asUInt64(),
         let totalDoses = cbor[CodingKeys.totalDoses]?.asUInt64(),
         let vaccinationDate = cbor[CodingKeys.vaccinationDate]?.asString(),
         let country = cbor[CodingKeys.country]?.asString(),
         let certIssuer = cbor[CodingKeys.certificateIssuer]?.asString(),
         let certIdentifier = cbor[CodingKeys.certificateIdentifier]?.asString() else {
            return nil
        }
        self.disease = disease
        self.vaccine = vaccine
        self.medicinialProduct = medicinialProduct
        self.marketingAuthorizationHolder = marketingAuthorizationHolder
        self.doseNumber = doseNumber
        self.totalDoses = totalDoses
        self.vaccinationDate = vaccinationDate
        self.country = country
        self.certificateIssuer = certIssuer
        self.certificateIdentifier = certIdentifier
    }
}

public struct Test : Codable {
    public let disease: String
    public let type: String
    public let testName: String?
    public let manufacturer: String?
    public let timestampSample: UInt64
    public let timestampResult : UInt64?
    public let result: String
    public let testCenter: String
    public let country: String
    public let certificateIssuer: String
    public let certificateIdentifier: String

    private enum CodingKeys : String, CodingKey {
        case disease = "tg"
        case type = "tt"
        case testName = "nm"
        case manufacturer = "ma"
        case timestampSample = "sc"
        case timestampResult = "dr"
        case result = "tr"
        case testCenter = "tc"
        case country = "co"
        case certificateIssuer = "is"
        case certificateIdentifier = "ci"
    }
    
    init?(from cbor: CBOR?) {
       guard let cbor = cbor?.asMap(),
              let disease = cbor[CodingKeys.disease]?.asString(),
              let type = cbor[CodingKeys.type]?.asString(),
              let timestampSample = cbor[CodingKeys.timestampSample]?.asUInt64(),
              let result = cbor[CodingKeys.result]?.asString(),
              let testCenter = cbor[CodingKeys.testCenter]?.asString(),
              let country = cbor[CodingKeys.country]?.asString(),
              let certIssuer = cbor[CodingKeys.certificateIssuer]?.asString(),
              let certIdentifier = cbor[CodingKeys.certificateIdentifier]?.asString() else {
            return nil
        }
        
        self.disease = disease
        self.type = type
        self.timestampSample = timestampSample
        self.result = result
        self.testCenter = testCenter
        self.country = country
        self.certificateIssuer = certIssuer
        self.certificateIdentifier = certIdentifier
        manufacturer = cbor[CodingKeys.manufacturer]?.asString()
        testName = cbor[CodingKeys.testName]?.asString()
        timestampResult = cbor[CodingKeys.timestampResult]?.asUInt64()
    }
}

public struct PastInfection : Codable {
    public let disease: String
    public let dateFirstPositiveTest: String
    public let countryOfTest: String
    public let certificateIssuer: String
    public let validFrom: String
    public let validUntil: String
    public let certificateIdentifier: String
    
    private enum CodingKeys : String, CodingKey {
        case disease = "tg"
        case dateFirstPositiveTest = "fr"
        case countryOfTest = "co"
        case certificateIssuer = "is"
        case validFrom = "df"
        case validUntil = "du"
        case certificateIdentifier = "ci"
    }
    
    init?(from cbor: CBOR?) {
        guard let cbor = cbor?.asMap(),
              let disease = cbor[CodingKeys.disease]?.asString(),
              let countryOfTest = cbor[CodingKeys.countryOfTest]?.asString(),
              let dateFirstPositiveTest = cbor[CodingKeys.dateFirstPositiveTest]?.asString(),
              let certIssuer = cbor[CodingKeys.certificateIssuer]?.asString(),
              let validFrom = cbor[CodingKeys.validFrom]?.asString(),
              let validUntil = cbor[CodingKeys.validUntil]?.asString(),
              let certIdentifier = cbor[CodingKeys.certificateIdentifier]?.asString() else {
            return nil
        }
        self.disease = disease
        self.countryOfTest = countryOfTest
        self.dateFirstPositiveTest = dateFirstPositiveTest
        self.certificateIssuer = certIssuer
        self.certificateIdentifier = certIdentifier
        self.validFrom = validFrom
        self.validUntil = validUntil
    }
}
