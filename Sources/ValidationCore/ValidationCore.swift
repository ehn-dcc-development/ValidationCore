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
    
    public init(){
        DDLog.add(DDOSLogger.sharedInstance)
    }

    
    //MARK: - Public API
    
    public mutating func validateQrCode(_ vc : UIViewController, prompt: String = "Scan QR Code", _ completionHandler: @escaping (Result<ValidationResult, ValidationError>) -> ()){
        self.completionHandler = completionHandler
        QrCodeScanner().scan(vc, prompt, self)
        //TODO scan qr code and pass to validate-method
//        let data = "AT016BFOXNMG2N9H8154TQ0TQ6E7W%M1TQ60JO DG*OY3WH:O*F9MN2SVUGL2-E64WFJRHQJAXRQ3E25SI:TU+MM0W5RX5TU12XENQ1DG6Y8TI0AEB9Q59C/96$PE%6AOMZL6BR9FGW15G7DAGWUG+SP+P$$QSJ0G 7G+SC%O4Q5%H06J0.L8CEK6.SC/VAT4*EIWC5/HL3 4HRICUH-+J70SBL02 EYOOQRA5RU2 E7R3V$6SYC00U2LL6468UEHFE2R6GS6IPEC46G8EA7N%17W56B0F2R6I%6%96LZ6/Q6AL6//6746-G9XL9TLR5DLE6COKEACBBYIU*1SZ43I0DS9CL5A 6YO6TP63CWTSOALU.GD.YGXV1%CWOXAA1Q-WT2-P.NI1$EV0EC:31QKR6UT2W**KIFF41F6JAHUVE3E5I89ESAGT8Z0O6M$1J7X7YTA$JDM+5CAG/E7K99RWE"
//        validate(encodedData: data, completionHandler)
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
            guard let cert = cert else {
                completionHandler(.failure(.CERTIFICATE_QUERY_FAILED))
                return
            }
            
            completionHandler(.success(ValidationResult(isValid: cose.hasValidSignature(for: cert), payload: cose.payload)))
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
    //Private: Scan QR Code (-> QR Code Helper from eID)
    
    private func cose(from data: Data) -> Cose? {
        let decoded = CBOR.decode(data.bytes)
        guard let tag = decoded as? NSTag,
              let tagObjectValue = tag.objectValue() as? [NSObject],
              let coseHeader = decodeHeader(from: tagObjectValue[0]),
              let cosePayload = decodePayload(from: tagObjectValue[2]),
              let coseSignature = (tagObjectValue[3] as? String)?.data
              else {
            return nil
        }
        let tagValue = tag.tagValue()
        let rawHeader = tagObjectValue[0].cborBytes
        let rawPayload = tagObjectValue[2].cborBytes
        
        return Cose(header: coseHeader, payload: cosePayload, signature: coseSignature, rawHeader: rawHeader, rawPayload: rawPayload)
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
