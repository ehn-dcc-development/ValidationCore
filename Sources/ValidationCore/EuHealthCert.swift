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
        self.version = try container.decode(String.self, forKey: .version)
        self.dateOfBirth = try container.decode(String.self, forKey: .dateOfBirth)
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
}

public struct Test : Codable {
    public let disease: String
    public let type: String
    public let testName: String?
    public let manufacturer: String?
    public let timestampSample: String
    public let timestampResult : String?
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
}

public struct Recovery : Codable {
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
}

