//
//  File.swift
//  
//
//  Created by Dominik Mocher on 26.04.21.
//

import Foundation

public protocol TrustlistService {
    func key(for keyId: Data, keyType: CertType, completionHandler: @escaping (Result<SecKey, ValidationError>)->())
    func key(for keyId: Data, cwt: CWT, keyType: CertType, completionHandler: @escaping (Result<SecKey, ValidationError>)->())
    func updateDataIfNecessary(completionHandler: @escaping (ValidationError?)->())
}

class DefaultTrustlistService : SignedDataService<TrustList>, TrustlistService {
    private let TRUSTLIST_FILENAME = "trustlist"
    private let TRUSTLIST_KEY_ALIAS = "trustlist_key"
    private let TRUSTLIST_KEYCHAIN_ALIAS = "trustlist_keychain"
    private let LAST_UPDATE_KEY = "last_trustlist_update"

    init(dateService: DateService, trustlistUrl: String, signatureUrl: String, trustAnchor: String) {
        super.init(dateService: dateService,
                   dataUrl: trustlistUrl,
                   signatureUrl: signatureUrl,
                   trustAnchor: trustAnchor,
                   updateInterval: TimeInterval(1.hour),
                   fileName: self.TRUSTLIST_FILENAME,
                   keyAlias: self.TRUSTLIST_KEY_ALIAS,
                   legacyKeychainAlias: self.TRUSTLIST_KEYCHAIN_ALIAS,
                   lastUpdateKey: self.LAST_UPDATE_KEY)
    }

    public func key(for keyId: Data, keyType: CertType, completionHandler: @escaping (Result<SecKey, ValidationError>)->()){
        key(for: keyId, keyType: keyType, cwt: nil, completionHandler: completionHandler)
    }

    public func key(for keyId: Data, cwt: CWT, keyType: CertType, completionHandler: @escaping (Result<SecKey, ValidationError>)->()){
        return key(for: keyId, keyType: keyType, cwt: cwt, completionHandler: completionHandler)
    }

    private func key(for keyId: Data, keyType: CertType, cwt: CWT?, completionHandler: @escaping (Result<SecKey, ValidationError>)->()){
        updateDataIfNecessary { _ in
            self.cachedKey(from: keyId, for: keyType, cwt: cwt, completionHandler)
        }
    }

    private func cachedKey(from keyId: Data, for keyType: CertType, cwt: CWT?, _ completionHandler: @escaping (Result<SecKey, ValidationError>)->()) {
        guard let entry = self.cachedData.entry(for: keyId) else {
            completionHandler(.failure(.KEY_NOT_IN_TRUST_LIST))
            return
        }
        guard entry.isValid(for: self.dateService) else {
            completionHandler(.failure(.PUBLIC_KEY_EXPIRED))
            return
        }
        guard entry.isSuitable(for: keyType) else {
            completionHandler(.failure(.UNSUITABLE_PUBLIC_KEY_TYPE))
            return
        }

        if let cwtIssuedAt = cwt?.issuedAt,
           let cwtExpiresAt = cwt?.expiresAt,
           let certNotBefore = entry.notBefore,
           let certNotAfter = entry.notAfter {
            guard certNotBefore.isBefore(cwtIssuedAt) && certNotAfter.isAfter(cwtIssuedAt) && certNotAfter.isAfter(cwtExpiresAt) else {
                completionHandler(.failure(.CWT_EXPIRED))
                return
            }
        }

        guard let secKey = entry.publicKey else {
            completionHandler(.failure(.KEY_CREATION_ERROR))
            return
        }
        completionHandler(.success(secKey))
    }
}
