//
//  EuHealthCert.swift
//  
//
//  Created by Dominik Mocher on 14.04.21.
//

import Foundation
import SwiftCBOR

public struct EuHealthCert {
    public let person: Person?
    public let vaccinations: [Vaccination]?
    public let pastInfections: [PastInfection]?
    public let tests: [Test]?
    public let certificateMetadata: CertificateMetadata?
    
    
    init(from cbor: CBOR) {
        person = Person(from: cbor["sub"])
        vaccinations = (cbor["vac"]?.asList())?.compactMap { Vaccination(from: $0) } ?? nil
        pastInfections = (cbor["rec"]?.asList())?.compactMap { PastInfection(from: $0) } ?? nil
        tests = (cbor["tst"]?.asList())?.compactMap { Test(from: $0) } ?? nil
        certificateMetadata = CertificateMetadata(from: cbor["cert"])
    }
}

public struct Person {
    public let givenName: String?
    public let familyName: String?
    public let birthDate: String?
    public let identifier: [Identifier?]?
    
    init?(from cbor: CBOR?) {
        guard let cbor = cbor else {
            return nil
        }
        givenName = cbor["gn"]?.asString()
        familyName = cbor["fn"]?.asString()
        birthDate = cbor["dob"]?.asString()
        identifier = (cbor["id"]?.asList())?.compactMap { Identifier(from: $0) } ?? nil
    }
}

public struct Identifier {
    public let system: String?
    public let value: String?
    
    private enum Keys : String {
        case system = "t"
        case value = "i"
    }
    
    init?(from cbor: CBOR?) {
        guard let cbor = cbor?.asMap() else {
            return nil
        }
        system = cbor[Keys.system]?.asString()
        value = cbor[Keys.value]?.asString()
    }
}

public struct Vaccination {
    public let disease: String?
    public let vaccine: String?
    public let medicinialProduct: String?
    public let marketingAuthorizationHolder: String?
    public let number: UInt64?
    public let numberOf: UInt64?
    public let lotNumber: String?
    public let vaccinationDate: String?
    public let administeringCenter: String?
    public let country: String?
    
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
        guard let cbor = cbor?.asMap() else {
            return nil
        }
        disease = cbor[Keys.disease]?.asString()
        vaccine = cbor[Keys.vaccine]?.asString()
        medicinialProduct = cbor[Keys.medicinialProduct]?.asString()
        marketingAuthorizationHolder = cbor[Keys.marketingAuthorizationHolder]?.asString()
        number = cbor[Keys.number]?.asUInt64()
        numberOf = cbor[Keys.numberOf]?.asUInt64()
        lotNumber = cbor[Keys.lotNumber]?.asString()
        vaccinationDate = cbor[Keys.vaccinationDate]?.asString()
        administeringCenter = cbor[Keys.administeringCenter]?.asString()
        country = cbor[Keys.country]?.asString()
    }
}

public struct PastInfection {
    public let disease: String?
    public let dateFirstPositiveTest: String?
    public let countryOfTest: String?
    
    private enum Keys : String {
        case disease = "dis"
        case dateFirstPositiveTest = "dat"
        case countryOfTest = "cou"
    }
    
    init?(from cbor: CBOR?) {
        guard let cbor = cbor?.asMap() else {
            return nil
        }
        disease = cbor[Keys.disease]?.asString()
        countryOfTest = cbor[Keys.countryOfTest]?.asString()
        dateFirstPositiveTest = cbor[Keys.dateFirstPositiveTest]?.asString()
    }
}

public struct CertificateMetadata {
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

public struct Test : Decodable {
    public let disease: String?
    public let type: String?
    public let name: String?
    public let manufacturer: String?
    public let sampleOrigin: String?
    public let timestampSample: String?
    public let timestampResult : String?
    public let result: String?
    public let facility: String?
    public let country: String?

    private enum Keys : String {
        case disease = "dis"
        case type = "typ"
        case name = "tna"
        case manufacturer = "tma"
        case sampleOrigin = "ori"
        case timestampSample = "dts"
        case timestampResult = "dtr"
        case result = "res"
        case facility = "fac"
        case country = "cou"
    }
    
    init?(from cbor: CBOR?) {
        guard let cbor = cbor?.asMap() else {
            return nil
        }
        disease = cbor[Keys.disease]?.asString()
        type = cbor[Keys.type]?.asString()
        name = cbor[Keys.name]?.asString()
        manufacturer = cbor[Keys.manufacturer]?.asString()
        sampleOrigin = cbor[Keys.sampleOrigin]?.asString()
        timestampSample = cbor[Keys.timestampSample]?.asString()
        timestampResult = cbor[Keys.timestampResult]?.asString()
        result = cbor[Keys.result]?.asString()
        facility = cbor[Keys.facility]?.asString()
        country = cbor[Keys.country]?.asString()
    }
}

