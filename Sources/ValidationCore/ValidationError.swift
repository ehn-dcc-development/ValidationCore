//
//  ValidationError.swift
//  
//
//  Created by Dominik Mocher on 07.04.21.
//

import Foundation

public enum ValidationError : Error, Equatable {
    case GENERAL_ERROR
    case INVALID_SCHEME_PREFIX
    case DECOMPRESSION_FAILED
    case BASE_45_DECODING_FAILED
    case COSE_DESERIALIZATION_FAILED
    case CBOR_DESERIALIZATION_FAILED
    case CWT_EXPIRED
    case QR_CODE_ERROR
    case CERTIFICATE_QUERY_FAILED
    case USER_CANCELLED
    case TRUST_SERVICE_ERROR(cause: String)
    case KEY_NOT_IN_TRUST_LIST
    case PUBLIC_KEY_EXPIRED
    case UNSUITABLE_PUBLIC_KEY_TYPE
    case KEY_CREATION_ERROR
    case KEYSTORE_ERROR(cause: String)
    

    public var message : String {
        switch self {
        case .GENERAL_ERROR: return "General error"
        case .INVALID_SCHEME_PREFIX: return "Invalid scheme prefix"
        case .DECOMPRESSION_FAILED: return "ZLib decompression failed"
        case .BASE_45_DECODING_FAILED: return "Base45 decoding failed"
        case .COSE_DESERIALIZATION_FAILED: return "COSE deserialization failed"
        case .CBOR_DESERIALIZATION_FAILED: return "CBOR deserialization failed"
        case .CWT_EXPIRED: return "CWT expired"
        case .QR_CODE_ERROR: return "QR code error"
        case .CERTIFICATE_QUERY_FAILED: return "Signing certificate query failed"
        case .USER_CANCELLED: return "User cancelled"
        case .TRUST_SERVICE_ERROR(let cause): return cause
        case .KEY_NOT_IN_TRUST_LIST: return "Key not in trust list"
        case .PUBLIC_KEY_EXPIRED: return "Public key expired"
        case .UNSUITABLE_PUBLIC_KEY_TYPE: return "Key unsuitable for EHN certificate type"
        case .KEY_CREATION_ERROR: return "Cannot create key from data"
        case .KEYSTORE_ERROR(let cause): return cause
        }
    }
}
