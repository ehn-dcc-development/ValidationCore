//
//  ValidationResult.swift
//  
//
//  Created by Dominik Mocher on 07.04.21.
//

import Foundation

public struct ValidationResult : Codable {
    public let isValid : Bool
    public let metaInformation : MetaInfo?
    public let greenpass : HealthCert?
    public let error : ValidationError?
}
