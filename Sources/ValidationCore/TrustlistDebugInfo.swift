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
    public let certDer: String
    public let certBase64 : String
    public let cert : String?
    public let keyId : String
}

public struct TrustlistInfo : Codable {
    public let expiration : Date
    public let downloadedAt: Date
    public let entries: Int
    public let url: String
    public var downloadLogUrl : String {
        get {
            if !url.contains("qr.gv.at") {
                return ""
            }
            return url.replacingOccurrences(of: "/trustlist", with: "/downloadlog")
        }
    }
}
