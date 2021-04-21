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
    public let vaccinations: [Vaccination]?
    public let pastInfections: [PastInfection]?
    public let tests: [Test]?
    public let certificateMetadata: CertificateMetadata?
    public let dgcid : String
    public let version: String
    
    private enum Keys : String {
        case person = "sub"
        case vaccinations = "vac"
        case pastInfections = "rec"
        case tests = "tst"
        case certificateMetadata = "cert"
        case dgcid = "dgcid"
        case version = "v"
    }
 
    init?(from cbor: CBOR) {
        guard let cbor = cbor.asMap(),
              let person = Person(from: cbor[Keys.person]),
              let dgcid = cbor[Keys.dgcid]?.asString(),
              let version = cbor[Keys.version]?.asString() else {
            return nil
        }
              
        self.person = person
        self.dgcid = dgcid
        self.version = version
        vaccinations = (cbor[Keys.vaccinations]?.asList())?.compactMap { Vaccination(from: $0) } ?? nil
        pastInfections = (cbor[Keys.pastInfections]?.asList())?.compactMap { PastInfection(from: $0) } ?? nil
        tests = (cbor[Keys.tests]?.asList())?.compactMap { Test(from: $0) } ?? nil
        certificateMetadata = CertificateMetadata(from: cbor[Keys.certificateMetadata])
    }
}

public struct Person : Codable {
    public let givenName: String
    public let familyName: String?
    public let birthDate: String
    public let gender: String?
    public let identifier: [Identifier?]?
    
    private enum Keys : String {
        case givenName = "gn"
        case familyName = "fn"
        case birthDate = "dob"
        case gender = "gen"
        case identifier = "id"
    }
 
    init?(from cbor: CBOR?) {
        guard let cbor = cbor?.asMap(),
              let givenName = cbor[Keys.givenName]?.asString(),
              let birthDate = cbor[Keys.birthDate]?.asString() else {
            return nil
        }
        self.givenName = givenName
        self.birthDate = birthDate
        self.gender = cbor[Keys.gender]?.asString()
        familyName = cbor[Keys.familyName]?.asString()
        identifier = (cbor[Keys.identifier]?.asList())?.compactMap { Identifier(from: $0) } ?? nil
    }
}

public struct Identifier : Codable {
    public let system: String
    public let value: String
    public let country: String?
    
    private enum Keys : String {
        case system = "t"
        case value = "i"
        case country = "c"
    }
    
    init?(from cbor: CBOR?) {
        guard let cbor = cbor?.asMap(),
              let system = cbor[Keys.system]?.asString(),
              let value = cbor[Keys.value]?.asString() else {
            return nil
        }
        self.system = system
        self.value = value
        country = cbor[Keys.country]?.asString()
    }
}

public struct Vaccination : Codable {
    public let disease: String
    public let vaccine: String
    public let medicinialProduct: String
    public let marketingAuthorizationHolder: String
    public let number: UInt64
    public let numberOf: UInt64
    public let lotNumber: String?
    public let vaccinationDate: String
    public let administeringCenter: String?
    public let country: String
    
    private enum Keys : String {
           case disease = "dis"
           case vaccine = "vap"
           case medicinialProduct = "mep"
           case marketingAuthorizationHolder = "aut"
           case number = "seq"
           case numberOf = "tot"
           case lotNumber = "lot"
           case vaccinationDate = "dat"
           case administeringCenter = "adm"
           case country = "cou"
    }
       
    init?(from cbor: CBOR?) {
        guard let cbor = cbor?.asMap(),
         let disease = cbor[Keys.disease]?.asString(),
         let vaccine = cbor[Keys.vaccine]?.asString(),
         let medicinialProduct = cbor[Keys.medicinialProduct]?.asString(),
         let marketingAuthorizationHolder = cbor[Keys.marketingAuthorizationHolder]?.asString(),
         let number = cbor[Keys.number]?.asUInt64(),
         let numberOf = cbor[Keys.numberOf]?.asUInt64(),
         let vaccinationDate = cbor[Keys.vaccinationDate]?.asString(),
         let country = cbor[Keys.country]?.asString() else {
            return nil
        }
        self.disease = disease
        self.vaccine = vaccine
        self.medicinialProduct = medicinialProduct
        self.marketingAuthorizationHolder = marketingAuthorizationHolder
        self.number = number
        self.numberOf = numberOf
        self.vaccinationDate = vaccinationDate
        self.country = country
        lotNumber = cbor[Keys.lotNumber]?.asString()
        administeringCenter = cbor[Keys.administeringCenter]?.asString()
    }
}

public struct Test : Codable {
    public let disease: String
    public let type: String
    public let manufacturer: String?
    public let sampleOrigin: String?
    public let timestampSample: String
    public let timestampResult : String
    public let result: String
    public let facility: String
    public let country: String

    private enum Keys : String {
        case disease = "dis"
        case type = "typ"
        case manufacturer = "tma"
        case sampleOrigin = "ori"
        case timestampSample = "dts"
        case timestampResult = "dtr"
        case result = "res"
        case facility = "fac"
        case country = "cou"
    }
    
    init?(from cbor: CBOR?) {
        guard let cbor = cbor?.asMap(),
              let disease = cbor[Keys.disease]?.asString(),
              let type = cbor[Keys.type]?.asString(),
              let timestampSample = cbor[Keys.timestampSample]?.asString(),
              let timestampResult = cbor[Keys.timestampResult]?.asString(),
              let result = cbor[Keys.result]?.asString(),
              let facility = cbor[Keys.facility]?.asString(),
              let country = cbor[Keys.country]?.asString() else {
            return nil
        }
        self.disease = disease
        self.type = type
        self.timestampSample = timestampSample
        self.timestampResult = timestampResult
        self.result = result
        self.facility = facility
        self.country = country
        manufacturer = cbor[Keys.manufacturer]?.asString()
        sampleOrigin = cbor[Keys.sampleOrigin]?.asString()
    }
}

public struct PastInfection : Codable {
    public let disease: String
    public let dateFirstPositiveTest: String
    public let countryOfTest: String
    
    private enum Keys : String {
        case disease = "dis"
        case dateFirstPositiveTest = "dat"
        case countryOfTest = "cou"
    }
    
    init?(from cbor: CBOR?) {
        guard let cbor = cbor?.asMap(),
              let disease = cbor[Keys.disease]?.asString(),
            let countryOfTest = cbor[Keys.countryOfTest]?.asString(),
            let dateFirstPositiveTest = cbor[Keys.dateFirstPositiveTest]?.asString() else {
            return nil
        }
        self.disease = disease
        self.countryOfTest = countryOfTest
        self.dateFirstPositiveTest = dateFirstPositiveTest
    }
}

public struct CertificateMetadata : Codable {
    public let issuer: String?
    public let identifier: String?
    public let validFrom: String?
    public let validUntil: String?
    public let validUntilextended: String?
    public let revokelistidentifier: String?
    public let schemaVersion: String?
    public let country: String?
    
    private enum Keys : String {
        case identifier = "id"
        case issuer = "is"
        case validFrom = "vf"
        case schemaVersion = "vr"
        case validUntil = "vu"
        case validUntilExtended = "validUntilextended"
        case revokeListIdentifier = "revokelistidentifier"
        case country = "co"
    }
    
    init?(from cbor: CBOR?) {
        guard let cbor = cbor?.asMap() else {
            return nil
        }
        identifier = cbor[Keys.identifier]?.asString()
        issuer = cbor[Keys.issuer]?.asString()
        validFrom = cbor[Keys.validFrom]?.asString()
        schemaVersion = cbor[Keys.schemaVersion]?.asString()
        validUntil = cbor[Keys.validUntil]?.asString()
        validUntilextended = cbor[Keys.validUntilExtended]?.asString()
        revokelistidentifier = cbor[Keys.revokeListIdentifier]?.asString()
        country = cbor[Keys.country]?.asString()
    }
}



