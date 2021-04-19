//
//  ValidationError.swift
//  
//
//  Created by Dominik Mocher on 07.04.21.
//

import Foundation

public enum ValidationError : String, Error {
    case GENERAL_ERROR = "General error"
    case INVALID_SCHEME_PREFIX = "Invalid scheme prefix"
    case DECOMPRESSION_FAILED = "ZLib decompression failed"
    case BASE_45_DECODING_FAILED = "Base45 decoding failed"
    case COSE_DESERIALIZATION_FAILED = "COSE deserialization failed"
    case CBOR_DESERIALIZATION_FAILED = "CBOR deserialization failed"
    case QR_CODE_ERROR = "QR code error"
    case CERTIFICATE_QUERY_FAILED = "Signing certificate query failed"
    case USER_CANCELLED = "User cancelled"
    
    public var message : String {
        get {
            return self.rawValue
        }
    }
}
