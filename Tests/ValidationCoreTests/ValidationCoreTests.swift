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
                    let correctEhnTestCert = TestDataProvider.correctEhnTestCert
                    self.mockSignatureCert(correctEhnTestCert.keyId, correctEhnTestCert.encodedSigningCert)
                    validationCore.validate(encodedData: correctEhnTestCert.encodedEhnCert) { result in
                        switch result {
                        case .success(let validationResult): expect(validationResult.isValid).to(be(true))
                        case .failure: XCTFail("Should not result in error")
                        }
                    }
                    
                }
                
                it("should verify correct vaccination certificate") {
                    let correctEhnVaccinationCert = TestDataProvider.correctEhnVaccinationCert
                    self.mockSignatureCert(correctEhnVaccinationCert.keyId, correctEhnVaccinationCert.encodedSigningCert)
                    validationCore.validate(encodedData: correctEhnVaccinationCert.encodedEhnCert) { result in
                        switch result {
                        case .success(let validationResult): expect(validationResult.isValid).to(be(true))
                        case .failure: XCTFail("Should not result in error")
                        }
                    }
                    
                }
                
                it("should verify correct recovery certificate") {
                    let correctEhnRecoveryCert = TestDataProvider.correctEhnRecoveryCert
                    self.mockSignatureCert(correctEhnRecoveryCert.keyId, correctEhnRecoveryCert.encodedSigningCert)
                    validationCore.validate(encodedData: correctEhnRecoveryCert.encodedEhnCert) { result in
                        switch result {
                        case .success(let validationResult): expect(validationResult.isValid).to(be(true))
                        case .failure: XCTFail("Should not result in error")
                        }
                    }
                }
                
                it("should verify certificate with RSA PSS signature"){
                    let rsaSignedCert = TestDataProvider.correctEhnRsaSignedVaccinationCert
                    self.mockSignatureCert(rsaSignedCert.keyId, rsaSignedCert.encodedSigningCert)
                    validationCore.validate(encodedData: rsaSignedCert.encodedEhnCert) { result in
                        switch result {
                        case .success(let validationResult): expect(validationResult.isValid).to(be(true))
                        case .failure: XCTFail("Should not result in error")
                        }
                    }
                }
            }
            
            /*context("can handle COSE specific characteristics"){
                it("can use keyId from unprotected header") {
                    //TODO
                }
                
                it("can use correct keyId if both header claims are set") {
                    //TODO
                }
            }*/
        }
    }
    
    private func mockSignatureCert(_ keyId : String, _ cert: String) {
        stub(condition: pathEndsWith(keyId)) { _ in
            return HTTPStubsResponse(data: cert.data(using: .utf8)!, statusCode: 200, headers: nil)
        }
    }
}
