//
//  TestDataProvider.swift
//  
//
//  Created by Dominik Mocher on 16.04.21.
//

import Foundation
import ValidationCore

class TestDataProvider {
    var testData = [EuTestData]()
    
    init(){
        testData = loadTestdata()
        addAdditionalTests()
    }
    
    private func jsonDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let value = try decoder.singleValueContainer()
            let formatter = ISO8601DateFormatter()
            let isoString = try value.decode(String.self)
            if let date = formatter.date(from: isoString) {
                return date
            }
            formatter.formatOptions = [.withFractionalSeconds]
            return formatter.date(from: isoString)!
        }
        return decoder
    }
    
    private func loadTestdata() -> [EuTestData] {
        var fileContents = [EuTestData]()
        let decoder = jsonDecoder()
        let url = Bundle.module.bundleURL.appendingPathComponent("Testdata")
        if let dirContent = try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: [.isDirectoryKey]) {
            for dir in dirContent.filter({ path in (try? path.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true }) {
                if let jsonFiles = try? FileManager.default.contentsOfDirectory(at: dir.appendingPathComponent("/2DCode/raw"), includingPropertiesForKeys: nil) {
                    let countryPrefix = dir.lastPathComponent
                    for file in jsonFiles.filter({ path in path.lastPathComponent.hasSuffix("json")}) {
                        if let content = FileManager.default.contents(atPath: file.path) {
                            do {
                                let filename = file.lastPathComponent.split(separator: ".")[0]
                                var testData = try decoder.decode(EuTestData.self, from: content)
                                testData.testContext.description = "\(countryPrefix)-\(filename)-\(testData.testContext.description)"
                                fileContents.append(testData)
                            } catch (let error) {
                                print("Parsing error in file \(file.path): \(error)")
                            }
                        }
                    }
                }
            }
        }
        return fileContents
    }
    
    private func addAdditionalTests() {
        if let testData = additionalTestData.data(using: .utf8),
           let additionalTests = try? jsonDecoder().decode([EuTestData].self, from: testData) {
            self.testData.append(contentsOf: additionalTests)
        }
    }
    
    let additionalTestData = """
[]
"""
    
    
    public var x509TestData : EuTestData {
        get {
            let jsonData = """
            {
                "PREFIX": "HC1:NCFTW2BM75VOO10KHHCUGEE45HB/J0DUIXEUKPAKGSITRD4PH.L0+6R.6USQN$9Q39V$K B9N3B2J7E31UN7ECHOXN5HM9QN$L9L-OWE4UNN88RTCVDCQF1E  NDLSUMBG%RVPBX*O4LT0B8NKF2WTR:5Z3EA-ND9IW$2:U7U$FOU6UVT2Y2/URB2NFPDT2J112748%F1+FNZDAI627U66I07VH7/BHE1E33CGCHGCD61Y6B JD1GINNG2Q39613E1Q-9B8G.SM1M8-EF1R8I64+E06/96QS9YP1D2%XK0SCBQRDFIBEGID1W34THEKFL36PX:G9TAB5F6UE/*SD3M4.BOLJ62WL23.4MXWN41BW37$DM:7E.QL%QLNDQN5NG8LWTD4KP8DB47TZX4-:P%E64NIJNOTYQNUAKL19TTZ/KM+D.%O+THCSL:%D%R41A65$GX720QRUE9K3M-UJ:/AWYBV3Q-L67VP1CN*GFN$VQ K9XLYQ81QUNOC4WR6NJK1OCUD2UT3XPY5MG6LW:B0GWU5N$J7QMNPAWX-1EQAMAFVZV4:M/*0:.943BX*PO7KIXRR7LG46Y%V WHMKH",
                "TESTCTX": {
                    "VERSION": 1,
                    "SCHEMA": "1.0.0",
                    "CERTIFICATE": "MIIBWDCB/6ADAgECAgRsvRZ/MAoGCCqGSM49BAMCMBAxDjAMBgNVBAMMBUVDLU1lMB4XDTIxMDUwMzE4MDAwMFoXDTIxMDYwMjE4MDAwMFowEDEOMAwGA1UEAwwFRUMtTWUwWTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAAQRS4GeBpNxSbvnbLY56NvXZ26gCJ2SwairBKQOuGqDTO3QMmyfNTH1sMg39aFDon51grJOyhKvEXXUaWD1LOLEo0cwRTAOBgNVHQ8BAf8EBAMCBaAwMwYDVR0lBCwwKgYMKwYBBAEAjjePZQEBBgwrBgEEAQCON49lAQIGDCsGAQQBAI43j2UBAzAKBggqhkjOPQQDAgNIADBFAiBjECR5mdD4++CGQGlV51CEhXjneiMvvVybCYrCjfES4QIhAMNHse2P4I9AokcT9D8pLEDdbbbTxjEvnjB/DFOb9Tho",
                    "VALIDATIONCLOCK": "2021-05-03T18:01:00Z",
                    "DESCRIPTION": "VALID: EC 256 key"
                },
                "EXPECTEDRESULTS": {
                    "EXPECTEDEXPIRATIONCHECK": false
                }
            }
            """.data(using: .utf8)!
            return try! jsonDecoder().decode(EuTestData.self, from: jsonData)
        }
    }
}

struct TestData {
    let encodedEhnCert : String
    let keyId : String
    let encodedSigningCert : String
}

struct EuTestData : Decodable {
    let jsonContent: EuHealthCert?
    let cborHex: String?
    let coseHex: String?
    let base45EncodedAndCompressed: String?
    let prefixed: String?
    let base64BarcodeImage: String?
    var testContext: TestContext
    let expectedResults: ExpectedResults
    
    enum CodingKeys: String, CodingKey {
        case jsonContent = "JSON"
        case cborHex = "CBOR"
        case coseHex = "COSE"
        case base45EncodedAndCompressed = "BASE45"
        case prefixed = "PREFIX"
        case base64BarcodeImage = "2DCODE"
        case testContext = "TESTCTX"
        case expectedResults = "EXPECTEDRESULTS"
    }
}

struct TestContext : Decodable {
    let version: Int?
    let schemaVersion: String?
    let signingCertificate: String?
    let validationClock: Date?
    var description: String
    
    enum CodingKeys: String, CodingKey {
        case version = "VERSION"
        case schemaVersion = "SCHEMA"
        case signingCertificate = "CERTIFICATE"
        case validationClock = "VALIDATIONCLOCK"
        case description = "DESCRIPTION"
    }
}

struct ExpectedResults : Decodable {
    let isValidObject: Bool?
    let isSchemeValidatable : Bool?
    let isEncodable: Bool?
    let isDecodable: Bool?
    let isVerifiable: Bool?
    let isUnprefixed: Bool?
    let isValidJson: Bool?
    let isBase45Decodable: Bool?
    let isImageDecodable: Bool?
    let isExpired: Bool?
    let isKeyUsageMatching: Bool?
    
    enum CodingKeys: String, CodingKey {
        case isValidObject = "EXPECTEDVALIDOBJECT"
        case isSchemeValidatable  = "EXPECTEDSCHEMAVALIDATION"
        case isEncodable = "EXPECTEDENCODE"
        case isDecodable = "EXPECTEDDECODE"
        case isVerifiable = "EXPECTEDVERIFY"
        case isUnprefixed = "EXPECTEDUNPREFIX"
        case isValidJson = "EXPECTEDVALIDJSON"
        case isBase45Decodable = "EXPECTEDB45DECODE"
        case isImageDecodable = "EXPECTEDPICTUREDECODE"
        case isExpired = "EXPECTEDEXPIRATIONCHECK"
        case isKeyUsageMatching = "EXPECTEDKEYUSAGE"
    }
}
