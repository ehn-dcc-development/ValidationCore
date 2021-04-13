import base45_swift
import CocoaLumberjackSwift
import Gzip
import CBORSwift
import UIKit

public struct ValidationCore {
    private let PREFIX = "AT01"
    private let CERT_SERVICE_URL = "https://dev.a-sit.at/certservice/"
    private let CERT_PATH = "cert/"

    
    private var completionHandler : ((Result<ValidationResult, ValidationError>) -> ())?
    private var scanner : QrCodeScanner?
    
    public init(){
        DDLog.add(DDOSLogger.sharedInstance)
    }

    
    //MARK: - Public API
    
    public mutating func validateQrCode(_ vc : UIViewController, prompt: String = "Scan QR Code", _ completionHandler: @escaping (Result<ValidationResult, ValidationError>) -> ()){
        self.completionHandler = completionHandler
        self.scanner = QrCodeScanner()
        scanner?.scan(vc, prompt, self)
    }
    
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

        guard let cose = cose(from: decompressedData) else {
            completionHandler(.failure(.COSE_DESERIALIZATION_FAILED))
            return
        }
        queryPublicKey(with: cose.header.keyId) { cert in
            completionHandler(.success(ValidationResult(isValid: cose.hasValidSignature(for: cert), payload: cose.payload.euHealthCert)))
        }
    }
    

    //MARK: - Helper Functions
    
    private func queryPublicKey(with keyId: String, _ completionHandler: @escaping (String?)->()) {
        guard let url = URL(string: "\(CERT_SERVICE_URL)\(CERT_PATH)\(keyId)") else { 
            DDLogError("Cannot construct certificate query url.")
            return
        }

        var request = URLRequest(url: url)
        request.addValue("text/plain", forHTTPHeaderField: "Accept")
        URLSession.shared.dataTask(with: request) { body, response, error in
            guard error == nil,
                  let status = (response as? HTTPURLResponse)?.statusCode,
                  200 == status,
                  let body = body else {
                DDLogError("Cannot query certificate.")
                completionHandler(nil)
                return
            }
            let encodedCert = String(data: body, encoding: .utf8)
            completionHandler(encodedCert)
        }.resume()
    }
    
    private func removeScheme(prefix: String, from encodedString: String) -> String? {
        guard encodedString.starts(with: prefix) else {
            DDLogError("Encoded data string does not seem to include prefix: \(encodedString.prefix(prefix.count))")
            return nil
        }
        return String(encodedString.dropFirst(prefix.count))
    }
    
    private func decode(_ encodedData: String) -> Data? {
        return try? encodedData.fromBase45()
    }
    
    private func decompress(_ encodedData: Data) -> Data? {
        //GZip uses ZLib internally
        return try? encodedData.gunzipped()
    }

    private func cose(from data: Data) -> Cose? {
        let decoded = CBOR.decode(data.bytes)
        guard let tag = decoded as? NSTag,
              let tagObjectValue = tag.objectValue() as? [NSObject],
              let coseHeader = decodeHeader(from: tagObjectValue[0]),
              let cwt = decodePayload(from: tagObjectValue[2]),
              let coseSignature = (tagObjectValue[3] as? String)?.data
              else {
            return nil
        }
        let rawHeader = tagObjectValue[0].cborBytes
        let rawPayload = tagObjectValue[2].cborBytes
        
//        let vaccinationData = EuHealthCert(from: cwt.payload)
        return Cose(header: coseHeader, payload: cwt, signature: coseSignature, rawHeader: rawHeader, rawPayload: rawPayload)
    }
    
    private func decodeHeader(from object: NSObject) -> CoseHeader? {
        guard let headerData = object.cborBytes else {
            DDLogError("Incorrect COSE header data.")
            return nil
        }
        return CoseHeader(from: CBOR.decode(headerData))
    }
    
}

extension ValidationCore : QrCodeReceiver {
    public func canceled() {
        DDLogDebug("QR code scanning cancelled.")
    }
    
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


extension Data{
 func humanReadable() -> String {
    return self.map { String(format: "%02x ", $0) }.joined()
 }
}

extension NSObject {
    var cborBytes : [UInt8]? {
        get {
            return (self as? String)?.data?.bytes
        }
    }
}
