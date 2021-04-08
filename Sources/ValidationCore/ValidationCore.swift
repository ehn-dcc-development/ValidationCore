import base45_swift
import CocoaLumberjackSwift
import Gzip
//import SwiftCBOR
import CBORSwift
import UIKit

public struct ValidationCore {
    private let PREFIX = "AT01"

    public init(){
        DDLog.add(DDOSLogger.sharedInstance)
    }

    
    //MARK: - Public API
    
    public func validateQrCode(_ completionHandler: @escaping (Result<ValidationResult, ValidationError>) -> ()){
        //TODO scan qr code and pass to validate-method
        let data = "AT016BFB 9W08AP2-532B16P0+IOK LDA6C:D1/JGVC*L1*UN9+5FJE49TMCIHSE*DSS+FG6U5DJQY7EJLFCHKT1NMG*$OY31N7SL 8VHQHJ8RBM$H1XW0:+4W9B/4Q+-GVTFUFVV0OCAWA:LZWMX*EYA5A.NFVN7+CXUTB/V09V5GCI3F NLGR227CBR2YSM+RI1-RZ$IDJPQUPXOO8BHJ$HDLMH94HY7XE6:LMWZVW+G5V2+9F/VDQUPZYCPZO8OG7DP8XC41RS KFTN+ ADOG1BS$OB/29NT2Z19HH44G0-BN0QO207Z%P%P3G90BX6EA7JWP-3HX.RFO3C$H- 5$AA8MA6-FALRB 32KGTJ90:6VZC16PXK0%OCE65D87W545D8QI1425ZWFMS11.N7T0-6LIJGJ+T5-CFEGRR3RPPH5SUYEXNNI/69*L-JG2YDPPL5RUEMR8 A*/2MRAW 6F0KMQBSYKQ+ABCS:X6U/KLTFFRLM%585G.OR131UB5W 4R2N30J$GFIE11P1O+V1-TEGMX9K/X9SYA+H6MX1U8WGK46-6CC9%.DO%VMIE0TO9$T3:77XFLTU HDF2SLWQQM1HPVQVKP2W39VM6J+TMT5HA2OL3OK8TGATZSEYPGG253*7L*J-IVO6R.7UYYQT8HJXL+KRM 3++N"
        validate(encodedData: data, completionHandler)
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
        //get public key and validate cose
        //get payload from cose
        //return success
        completionHandler(.failure(.GENERAL_ERROR))
    }
    

    //MARK: - Helper Functions
    
    private func queryPublicKey(with keyId: String) -> String {
        //TODO get key from certservice
        return ""
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
        
        return Cose(header: coseHeader, payload: cosePayload, signature: coseSignature)
    }
    
    private func decodeHeader(from object: NSObject) -> CoseHeader? {
        guard let headerData = object.cborBytes else {
            DDLogError("Incorrect COSE header data.")
            return nil
        }
        return CoseHeader(from: CBOR.decode(headerData))
    }
    
    private func decodePayload(from object: NSObject) -> NSObject? {
        guard let payload = object.cborBytes else {
            DDLogError("Cannot decode COSE payload.")
            return nil
        }
        return CBOR.decode(payload) //TODO fix payload decoding
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
