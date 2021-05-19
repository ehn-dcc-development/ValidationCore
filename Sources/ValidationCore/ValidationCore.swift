import base45_swift
import CocoaLumberjackSwift
import Gzip
#if canImport(UIKit)
import UIKit
#else
import Foundation
#endif

/// Electronic Health Certificate Validation Core
///
/// This struct provides an interface for validating EHN Health certificates generated by https://dev.a-sit.at/certservice
public struct ValidationCore {
    private let PREFIX = "HC1:"

    private var completionHandler : ((Result<ValidationResult, ValidationError>) -> ())?
    #if canImport(UIKit)
    private var scanner : QrCodeScanner?
    #endif
    private let trustlistService : TrustlistService
    private let dateService : DateService

    public init(trustlistService: TrustlistService? = nil, dateService: DateService? = nil ){
        self.trustlistService = trustlistService ?? DefaultTrustlistService()
        self.dateService = dateService ?? DefaultDateService()
        DDLog.add(DDOSLogger.sharedInstance)
   }

    //MARK: - Public API
    
    #if canImport(UIKit)
    /// Instantiate a QR code scanner and validate the scannned EHN health certificate
    public mutating func validateQrCode(_ qrView : UIView, _ completionHandler: @escaping (Result<ValidationResult, ValidationError>) -> ()){
        self.completionHandler = completionHandler
        self.scanner = QrCodeScanner()
        scanner?.scan(qrView, self)
    }
    #endif
    
    /// Validate an Base45-encoded EHN health certificate
    public func validate(encodedData: String, _ completionHandler: @escaping (Result<ValidationResult, ValidationError>) -> ()) {
        DDLogInfo("Starting validation")
        guard let unprefixedEncodedString = removeScheme(prefix: PREFIX, from: encodedData) else {
            completionHandler(.failure(.INVALID_SCHEME_PREFIX))
            return
        }
        
        guard let decodedData = decode(unprefixedEncodedString) else {
            completionHandler(.failure(.BASE_45_DECODING_FAILED))
            return
        }
        DDLogDebug("Base45-decoded data: \(decodedData.humanReadable())")
        
        guard let decompressedData = decompress(decodedData) else {
            completionHandler(.failure(.DECOMPRESSION_FAILED))
            return
        }
        DDLogDebug("Decompressed data: \(decompressedData.humanReadable())")

        guard let cose = cose(from: decompressedData),
              let keyId = cose.keyId else {
            completionHandler(.failure(.COSE_DESERIALIZATION_FAILED))
            return
        }
        
        guard let cwt = CWT(from: cose.payload) else {
            completionHandler(.failure(.CBOR_DESERIALIZATION_FAILED))
            return
        }
        
        guard cwt.isValid(using: dateService) else {
            completionHandler(.failure(.CWT_EXPIRED))
            return
        }

        trustlistService.key(for: keyId, keyType: cwt.euHealthCert.type) { result in
            switch result {
            case .success(let key): completionHandler(.success(ValidationResult(isValid: cose.hasValidSignature(for: key), payload: cwt.euHealthCert)))
            case .failure(let error): completionHandler(.failure(error))
            }
        }
    }

    public func updateTrustlist(completionHandler: @escaping (ValidationError?)->()) {
        trustlistService.updateTrustlist(completionHandler: completionHandler)
    }

    //MARK: - Helper Functions

    /// Strips a given scheme prefix from the encoded EHN health certificate
    private func removeScheme(prefix: String, from encodedString: String) -> String? {
        guard encodedString.starts(with: prefix) else {
            DDLogError("Encoded data string does not seem to include scheme prefix: \(encodedString.prefix(prefix.count))")
            return nil
        }
        return String(encodedString.dropFirst(prefix.count))
    }
    
    /// Base45-decodes an EHN health certificate
    private func decode(_ encodedData: String) -> Data? {
        return try? encodedData.fromBase45()
    }
    
    /// Decompress the EHN health certificate using ZLib
    private func decompress(_ encodedData: Data) -> Data? {
        return try? encodedData.gunzipped()
    }

    /// Creates COSE structure from EHN health certificate
    private func cose(from data: Data) -> Cose? {
       return Cose(from: data)
    }
    
}

// MARK: - QrCodeReceiver
#if canImport(UIKit)
extension ValidationCore : QrCodeReceiver {
    public func canceled() {
        DDLogDebug("QR code scanning cancelled.")
        completionHandler?(.failure(.USER_CANCELLED))
    }
    
    /// Process the scanned EHN health certificate
    public func onQrCodeResult(_ result: String?) {
        guard let result = result,
              let completionHandler = self.completionHandler else {
            DDLogError("Cannot read QR code.")
            self.completionHandler?(.failure(.QR_CODE_ERROR))
            return
        }
        validate(encodedData: result, completionHandler)
    }
}
#endif


