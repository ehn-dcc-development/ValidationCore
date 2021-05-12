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
            formatter.formatOptions = .withFractionalSeconds
            let iso8601FractionalSecondString = try value.decode(String.self)
            return formatter.date(from: iso8601FractionalSecondString)!
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
