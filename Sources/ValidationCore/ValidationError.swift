//
//  ValidationError.swift
//  
//
//  Created by Dominik Mocher on 07.04.21.
//

import Foundation

public enum ValidationError : Error {
    case GENERAL_ERROR
    case INVALID_SCHEME_PREFIX
    case DECOMPRESSION_FAILED
    case BASE_45_DECODING_FAILED
    case COSE_DESERIALIZATION_FAILED
    case CBOR_DESERIALIZATION_FAILED
    case INVALID_JSON_PAYLOAD
    case QR_CODE_ERROR
    case CERTIFICATE_QUERY_FAILED
}
