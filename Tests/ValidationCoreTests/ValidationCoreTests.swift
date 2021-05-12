import Foundation
import Quick
import Nimble
import OHHTTPStubsSwift
import OHHTTPStubs
import XCTest
import ValidationCore


class ValidationCoreSpec: QuickSpec {
    
    override func spec() {
        describe("The validation core") {
            
            var validationCore : ValidationCore!
            let testDataProvider : TestDataProvider! = TestDataProvider()
            
            beforeEach {
            }
            
            context("generated"){
                for testData in testDataProvider.testData {
                    it(testData.testContext.description) {
                        let trustlistService = TestTrustlistService(testData.testContext)
                        let dateService = TestDateService(testData)
                        validationCore = ValidationCore(trustlistService: trustlistService, dateService: dateService)
                        guard let prefixedEncodedCert = testData.prefixed else {
                            XCTFail("QR code payload missing")
                            return
                        }
                        validationCore.validate(encodedData: prefixedEncodedCert) { result in
                            switch result {
                            case .success(let validationResult): self.map(validationResult, to: testData)
                            case .failure(let error): self.map(error, to: testData.expectedResults)
                            }
                        }
                    }
                }
            }
        }
    }

    private func map(_ validationResult: ValidationResult, to testData: EuTestData){
        let expectedResults = testData.expectedResults
        if true == expectedResults.isSchemeValidatable {
            expect(validationResult.payload).to(beHealthCert(testData.jsonContent))
        }
        
        if let verifiable = expectedResults.isVerifiable {
            expect(validationResult.isValid == verifiable).to(beTrue())
        }
    }
    
    private func map(_ error: ValidationError, to expectedResults: ExpectedResults){
        if false == expectedResults.isUnprefixed {
            expect(error).to(beError(.INVALID_SCHEME_PREFIX))
        }
        if false == expectedResults.isBase45Decodable {
            expect(error).to(beError(.BASE_45_DECODING_FAILED))
        }
        if false == expectedResults.isExpired {
            expect(error).to(beError(.CWT_EXPIRED))
        }
        if false == expectedResults.isVerifiable {
            expect(error).to(beError(.COSE_DESERIALIZATION_FAILED))
        }
        if false == expectedResults.isDecodable {
            expect(error).to(beError(.CBOR_DESERIALIZATION_FAILED))
        }
        if false == expectedResults.isKeyUsageMatching {
            expect(error).to(beError(.UNSUITABLE_PUBLIC_KEY_TYPE))
        }
    }
}
