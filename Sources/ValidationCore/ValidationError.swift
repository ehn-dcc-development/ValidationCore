//
//  ValidationError.swift
//  
//
//  Created by Dominik Mocher on 07.04.21.
//

import Foundation

public enum ValidationError : String, Error, Codable {
    case GENERAL_ERROR = "GENERAL_ERROR"
    case INVALID_SCHEME_PREFIX = "INVALID_SCHEME_PREFIX"
    case DECOMPRESSION_FAILED = "DECOMPRESSION_FAILED"
    case BASE_45_DECODING_FAILED = "BASE_45_DECODING_FAILED"
    case COSE_DESERIALIZATION_FAILED = "COSE_DESERIALIZATION_FAILED"
    case CBOR_DESERIALIZATION_FAILED = "CBOR_DESERIALIZATION_FAILED"
    case CWT_EXPIRED = "CWT_EXPIRED"
    case CWT_NOT_YET_VALID = "CWT_NOT_YET_VALID"
    case QR_CODE_ERROR = "QR_CODE_ERROR"
    case CERTIFICATE_QUERY_FAILED = "CERTIFICATE_QUERY_FAILED"
    case USER_CANCELLED = "USER_CANCELLED"
    case TRUST_SERVICE_ERROR = "TRUST_SERVICE_ERROR"
    case KEY_NOT_IN_TRUST_LIST = "KEY_NOT_IN_TRUST_LIST"
    case PUBLIC_KEY_EXPIRED = "PUBLIC_KEY_EXPIRED"
    case PUBLIC_KEY_NOT_YET_VALID = "PUBLIC_KEY_NOT_YET_VALID"
    case UNSUITABLE_PUBLIC_KEY_TYPE = "UNSUITABLE_PUBLIC_KEY_TYPE"
    case KEY_CREATION_ERROR = "KEY_CREATION_ERROR"
    case KEYSTORE_ERROR = "KEYSTORE_ERROR"
    case SIGNATURE_INVALID = "SIGNATURE_INVALID"
    case TRUST_LIST_SIGNATURE_INVALID = "TRUST_LIST_SIGNATURE_INVALID"
    case TRUST_LIST_NOT_YET_VALID = "TRUST_LIST_NOT_YET_VALID"
    case TRUST_LIST_EXPIRED = "TRUST_LIST_EXPIRED"
    
    case DATA_EXPIRED = "DATA_EXPIRED"
    

    public var message : String {
        switch self {
        case .GENERAL_ERROR: return "General error"
        case .INVALID_SCHEME_PREFIX: return "Invalid scheme prefix"
        case .DECOMPRESSION_FAILED: return "ZLib decompression failed"
        case .BASE_45_DECODING_FAILED: return "Base45 decoding failed"
        case .COSE_DESERIALIZATION_FAILED: return "COSE deserialization failed"
        case .CBOR_DESERIALIZATION_FAILED: return "CBOR deserialization failed"
        case .CWT_EXPIRED: return "CWT expired"
        case .CWT_NOT_YET_VALID: return "CWT not yet valid"
        case .QR_CODE_ERROR: return "QR code error"
        case .CERTIFICATE_QUERY_FAILED: return "Signing certificate query failed"
        case .USER_CANCELLED: return "User cancelled"
        case .TRUST_SERVICE_ERROR: return "Trust Service Error"
        case .KEY_NOT_IN_TRUST_LIST: return "Key not in trust list"
        case .PUBLIC_KEY_EXPIRED: return "Public key expired"
        case .PUBLIC_KEY_NOT_YET_VALID: return "Public key not yet valid"
        case .UNSUITABLE_PUBLIC_KEY_TYPE: return "Key unsuitable for EHN certificate type"
        case .KEY_CREATION_ERROR: return "Cannot create key from data"
        case .SIGNATURE_INVALID: return "Signature is not valid"
        case .KEYSTORE_ERROR: return "Keystore error"
        case .TRUST_LIST_SIGNATURE_INVALID: return "Trustlist signature is not valid"
        case .TRUST_LIST_NOT_YET_VALID: return "Trustlist is not yet valid"
        case .TRUST_LIST_EXPIRED: return "Trustlist is expired"
            
        case .DATA_EXPIRED: return "Cached data expired"
        }
    }
}
