//
//  TrustlistDebugInfo.swift
//  
//
//  Created by Dominik Mocher on 17.11.21.
//

import Foundation

public struct TrustlistDebugInfo {
    let signatureCertInfo : SignatureCertInfo?
    let trustlistInfo : TrustlistInfo
    let trustlistErrors : [ValidationError]?
    
    public init(signatureCertInfo: SignatureCertInfo?, trustlistExpiration: Date, trustlistDownloadedAt: Date, trustlistUrl: String, trustlistEntries: Int, errors: [ValidationError]?) {
        self.signatureCertInfo = signatureCertInfo
        self.trustlistInfo = TrustlistInfo(expiration: trustlistExpiration, downloadedAt: trustlistDownloadedAt, entries: trustlistEntries, url: trustlistUrl)
        self.trustlistErrors = errors
    }
}

public struct SignatureCertInfo : Codable {
    let certDer: String
    let certBase64 : String
    let cert : String?
    let keyId : String
}

public struct TrustlistInfo : Codable {
    let expiration : Date
    let downloadedAt: Date
    let entries: Int
    let url: String
    var downloadLogUrl : String {
        get {
            if !url.contains("qr.gv.at") {
                return ""
            }
            return "\(url)/downloadlog"
        }
    }
}
