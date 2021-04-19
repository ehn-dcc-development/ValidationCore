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
            
            beforeEach {
                validationCore = ValidationCore()
            }
            
            context("process complete certificates and"){
                it("should verify correct test certificate") {
                    let correctEhnTestCert = TestDataProvider.Correct.ehnTestCertificate
                    self.mockSignatureCert(correctEhnTestCert.keyId, correctEhnTestCert.encodedSigningCert)
                    validationCore.validate(encodedData: correctEhnTestCert.encodedEhnCert) { result in
                        switch result {
                        case .success(let validationResult): expect(validationResult.isValid).to(be(true))
                        case .failure: XCTFail("Should not result in error")
                        }
                    }
                    
                }
                
                it("should verify correct vaccination certificate") {
                    let correctEhnVaccinationCert = TestDataProvider.Correct.ehnVaccinationCert
                    self.mockSignatureCert(correctEhnVaccinationCert.keyId, correctEhnVaccinationCert.encodedSigningCert)
                    validationCore.validate(encodedData: correctEhnVaccinationCert.encodedEhnCert) { result in
                        switch result {
                        case .success(let validationResult): expect(validationResult.isValid).to(be(true))
                        case .failure: XCTFail("Should not result in error")
                        }
                    }
                    
                }
                
                it("should verify correct recovery certificate") {
                    let correctEhnRecoveryCert = TestDataProvider.Correct.ehnRecoveryCert
                    self.mockSignatureCert(correctEhnRecoveryCert.keyId, correctEhnRecoveryCert.encodedSigningCert)
                    validationCore.validate(encodedData: correctEhnRecoveryCert.encodedEhnCert) { result in
                        switch result {
                        case .success(let validationResult): expect(validationResult.isValid).to(be(true))
                        case .failure: XCTFail("Should not result in error")
                        }
                    }
                }
                
                it("should verify certificate with RSA PSS signature"){
                    let rsaSignedCert = TestDataProvider.Correct.ehnRsaSignedVaccinationCert
                    self.mockSignatureCert(rsaSignedCert.keyId, rsaSignedCert.encodedSigningCert)
                    validationCore.validate(encodedData: rsaSignedCert.encodedEhnCert) { result in
                        switch result {
                        case .success(let validationResult): expect(validationResult.isValid).to(be(true))
                        case .failure: XCTFail("Should not result in error")
                        }
                    }
                }
            }
            
            context("can handle COSE specific characteristics"){
                it("does not accept alg in unprotected header") {
                    let incorrectEhnCert = TestDataProvider.Failure.unprotectedAlgHeader
                    self.mockSignatureCert(incorrectEhnCert.keyId, incorrectEhnCert.encodedSigningCert)
                    validationCore.validate(encodedData: incorrectEhnCert.encodedEhnCert) { result in
                        switch result {
                        case .success: XCTFail("Should not be able to deserialize incorrect CWT")
                        case .failure(let error): expect(error).to(beError(ValidationError.COSE_DESERIALIZATION_FAILED))
                        }
                    }
                }
           }
        }
    }
    
    private func mockSignatureCert(_ keyId : String, _ cert: String) {
        stub(condition: pathEndsWith(keyId)) { _ in
            return HTTPStubsResponse(data: cert.data(using: .utf8)!, statusCode: 200, headers: nil)
        }
    }
}
