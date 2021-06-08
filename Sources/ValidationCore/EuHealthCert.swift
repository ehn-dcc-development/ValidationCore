//
//  EuHealthCert.swift
//  
//
//  Created by Dominik Mocher on 14.04.21.
//

import Foundation
import SwiftCBOR

fileprivate let SCHEMA_LENGTH_LIMIT = 50

public struct EuHealthCert : Codable {
    public let person: Person
    public let dateOfBirth : String
    public let version: String
    public let vaccinations: [Vaccination]?
    public let recovery: [Recovery]?
    public let tests: [Test]?
    
    var type : CertType {
        get {
            switch self {
            case _ where nil != vaccinations:
                return .vaccination
            case _ where nil != recovery:
                return .recovery
            default:
                return .test
            }
        }
    }
    
    private enum CodingKeys : String, CodingKey {
        case person = "nam"
        case dateOfBirth = "dob"
        case vaccinations = "v"
        case recovery = "r"
        case tests = "t"
        case version = "ver"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.person = try container.decode(Person.self, forKey: .person)
        let version = try container.decode(String.self, forKey: .version)
        guard version.conformsTo(regex: "^\\d+.\\d+.\\d+$") else {
            throw ValidationError.CBOR_DESERIALIZATION_FAILED
        }
        self.version = version
        let dateOfBirth = try container.decode(String.self, forKey: .dateOfBirth)
        guard dateOfBirth.conformsTo(regex: "^(19|20)\\d\\d(-\\d\\d){0,2}$") else {
            throw ValidationError.CBOR_DESERIALIZATION_FAILED
        }
        self.dateOfBirth = dateOfBirth
        self.vaccinations = try? container.decode([Vaccination].self, forKey: .vaccinations)
        self.tests = try? container.decode([Test].self, forKey: .tests)
        self.recovery = try? container.decode([Recovery].self, forKey: .recovery)
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
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.givenName = try? container.decode(String.self, forKey: .givenName)
        if let givenName = givenName, givenName.count > SCHEMA_LENGTH_LIMIT {
            throw ValidationError.CBOR_DESERIALIZATION_FAILED
        }
        self.standardizedGivenName = try? container.decode(String.self, forKey: .standardizedGivenName)
        if let standardizedGivenName = standardizedGivenName, !standardizedGivenName.conformsTo(regex: "^[A-Z<]*$") {
            throw ValidationError.CBOR_DESERIALIZATION_FAILED
        }
        self.familyName = try? container.decode(String.self, forKey: .familyName)
        if let familyName = familyName, familyName.count > SCHEMA_LENGTH_LIMIT {
            throw ValidationError.CBOR_DESERIALIZATION_FAILED
        }
        self.standardizedFamilyName = try container.decode(String.self, forKey: .standardizedFamilyName)
        if !standardizedFamilyName.conformsTo(regex: "^[A-Z<]*$") {
            throw ValidationError.CBOR_DESERIALIZATION_FAILED
        }
    }
}

public struct Vaccination : Codable {
    public let disease: DiseaseAgentTargeted
    public let vaccine: VaccineProphylaxis
    public let medicinialProduct: VaccineMedicinialProduct
    public let marketingAuthorizationHolder: VaccineManufacturer
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
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.disease = try container.decode(DiseaseAgentTargeted.self, forKey: .disease)
        self.vaccine = try container.decode(VaccineProphylaxis.self, forKey: .vaccine)
        self.medicinialProduct = try container.decode(VaccineMedicinialProduct.self, forKey: .medicinialProduct)
        self.marketingAuthorizationHolder = try container.decode(VaccineManufacturer.self, forKey: .marketingAuthorizationHolder)
        self.doseNumber = try container.decode(UInt64.self, forKey: .doseNumber)
        guard 1..<10 ~= doseNumber else {
            throw ValidationError.CBOR_DESERIALIZATION_FAILED
        }
        self.totalDoses = try container.decode(UInt64.self, forKey: .totalDoses)
        guard 1..<10 ~= totalDoses else {
            throw ValidationError.CBOR_DESERIALIZATION_FAILED
        }
        self.vaccinationDate = try container.decode(String.self, forKey: .vaccinationDate)
        guard vaccinationDate.isValidIso8601Date() else {
            throw ValidationError.CBOR_DESERIALIZATION_FAILED
        }
        self.country = try container.decode(String.self, forKey: .country)
        guard country.conformsTo(regex: "[A-Z]{1,10}") else {
            throw ValidationError.CBOR_DESERIALIZATION_FAILED
        }
        self.certificateIssuer = try container.decode(String.self, forKey: .certificateIssuer)
        guard certificateIssuer.count <= SCHEMA_LENGTH_LIMIT else {
            throw ValidationError.CBOR_DESERIALIZATION_FAILED
        }
        self.certificateIdentifier = try container.decode(String.self, forKey: .certificateIdentifier)
        guard certificateIdentifier.count <= SCHEMA_LENGTH_LIMIT else {
            throw ValidationError.CBOR_DESERIALIZATION_FAILED
        }
    }
}

public struct Test : Codable {
    public let disease: DiseaseAgentTargeted
    public let type: TestType
    public let testName: String?
    public let manufacturer: TestManufacturer?
    public let timestampSample: String
    public let timestampResult : String?
    public let result: TestResult
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
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.disease = try container.decode(DiseaseAgentTargeted.self, forKey: .disease)
        self.type = try container.decode(TestType.self, forKey: .type)
        self.testName = try? container.decode(String.self, forKey: .testName)
        
        self.manufacturer = try? container.decode(TestManufacturer.self, forKey: .manufacturer)
        self.timestampSample = try container.decode(String.self, forKey: .timestampSample)
        guard timestampSample.isValidIso8601DateTime() else {
            throw ValidationError.CBOR_DESERIALIZATION_FAILED
        }
        self.timestampResult = try? container.decode(String.self, forKey: .timestampResult )
        if let timestampResult = timestampResult, !timestampResult.isValidIso8601DateTime() {
            throw ValidationError.CBOR_DESERIALIZATION_FAILED
        }
        self.result = try container.decode(TestResult.self, forKey: .result)
        let testCenter = try container.decode(String.self, forKey: .testCenter)
        guard testCenter.count <= SCHEMA_LENGTH_LIMIT else {
            throw ValidationError.CBOR_DESERIALIZATION_FAILED
        }
        self.testCenter = testCenter
        self.country = try container.decode(String.self, forKey: .country)
        guard country.conformsTo(regex: "[A-Z]{1,10}") else {
            throw ValidationError.CBOR_DESERIALIZATION_FAILED
        }
        self.certificateIssuer = try container.decode(String.self, forKey: .certificateIssuer)
        guard certificateIssuer.count <= SCHEMA_LENGTH_LIMIT else {
            throw ValidationError.CBOR_DESERIALIZATION_FAILED
        }
        self.certificateIdentifier = try container.decode(String.self, forKey: .certificateIdentifier)
        guard certificateIdentifier.count <= SCHEMA_LENGTH_LIMIT else {
            throw ValidationError.CBOR_DESERIALIZATION_FAILED
        }
    }
    
}

public struct Recovery : Codable {
    public let disease: DiseaseAgentTargeted
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
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.disease = try container.decode(DiseaseAgentTargeted.self, forKey: .disease)
        let dateFirstPositiveTest = try container.decode(String.self, forKey: .dateFirstPositiveTest)
        guard dateFirstPositiveTest.isValidIso8601Date() else {
            throw ValidationError.CBOR_DESERIALIZATION_FAILED
        }
        self.dateFirstPositiveTest = dateFirstPositiveTest
        self.countryOfTest = try container.decode(String.self, forKey: .countryOfTest)
        guard countryOfTest.conformsTo(regex: "[A-Z]{1,10}") else {
            throw ValidationError.CBOR_DESERIALIZATION_FAILED
        }
        self.validFrom = try container.decode(String.self, forKey: .validFrom)
        guard validFrom.isValidIso8601Date() else {
            throw ValidationError.CBOR_DESERIALIZATION_FAILED
        }
        self.validUntil = try container.decode(String.self, forKey: .validUntil)
        guard validUntil.isValidIso8601Date() else {
            throw ValidationError.CBOR_DESERIALIZATION_FAILED
        }
        self.certificateIssuer = try container.decode(String.self, forKey: .certificateIssuer)
        guard certificateIssuer.count <= SCHEMA_LENGTH_LIMIT else {
            throw ValidationError.CBOR_DESERIALIZATION_FAILED
        }
        self.certificateIdentifier = try container.decode(String.self, forKey: .certificateIdentifier)
        guard certificateIdentifier.count <= SCHEMA_LENGTH_LIMIT else {
            throw ValidationError.CBOR_DESERIALIZATION_FAILED
        }
    }
}
