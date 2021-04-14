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
    
    init?(from cbor: CBOR?) {
        guard let cbor = cbor else {
            return nil
        }
        system = cbor["t"]?.asString()
        value = cbor["i"]?.asString()
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
    public let administeringCentre: String?
    public let country: String?
    
    init?(from cbor: CBOR?) {
        guard let cbor = cbor else {
            return nil
        }
        disease = cbor["dis"]?.asString()
        vaccine = cbor["vap"]?.asString()
        medicinialProduct = cbor["mep"]?.asString()
        marketingAuthorizationHolder = cbor["aut"]?.asString()
        number = cbor["seq"]?.asUInt64()
        numberOf = cbor["tot"]?.asUInt64()
        lotNumber = cbor["lot"]?.asString()
        vaccinationDate = cbor["dat"]?.asString()
        administeringCentre = cbor["adm"]?.asString()
        country = cbor["cou"]?.asString()
    }
}

public struct PastInfection {
    public let disease: String?
    public let dateFirstPositiveTest: String?
    public let countryOfTest: String?
    
    init?(from cbor: CBOR?) {
        guard let cbor = cbor else {
            return nil
        }
        disease = cbor["dis"]?.asString()
        countryOfTest = cbor["cou"]?.asString()
        dateFirstPositiveTest = cbor["dat"]?.asString()
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
    
    init?(from cbor: CBOR?) {
        guard let cbor = cbor else {
            return nil
        }
        identifier = cbor["id"]?.asString()
        issuer = cbor["is"]?.asString()
        validFrom = cbor["vf"]?.asString()
        schemaVersion = cbor["vr"]?.asString()
        validUntil = cbor["vu"]?.asString()
        validUntilextended = cbor["validUntilextended"]?.asString()
        revokelistidentifier = cbor["revokelistidentifier"]?.asString()
        country = cbor["co"]?.asString()
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

    init?(from cbor: CBOR?) {
        guard let cbor = cbor else {
            return nil
        }
        disease = cbor["dis"]?.asString()
        type = cbor["typ"]?.asString()
        name = cbor["tna"]?.asString()
        manufacturer = cbor["tma"]?.asString()
        sampleOrigin = cbor["ori"]?.asString()
        timestampSample = cbor["dts"]?.asString()
        timestampResult = cbor["dtr"]?.asString()
        result = cbor["res"]?.asString()
        facility = cbor["fac"]?.asString()
        country = cbor["cou"]?.asString()
    }
}

