//
//  File.swift
//  
//
//  Created by Dominik Mocher on 26.04.21.
//

import Foundation
import SwiftCBOR
import CocoaLumberjackSwift
import Security

public protocol TrustlistService {
    func key(for keyId: Data, keyType: CertType, completionHandler: @escaping (Result<SecKey, ValidationError>)->())
    func updateTrustlist(completionHandler: @escaping (ValidationError?)->())
}

    class DefaultTrustlistService : TrustlistService {
    private let CERT_SERVICE_URL = "https://dgc.a-sit.at/ehn/"
    private let TRUST_LIST_PATH = "cert/list"
    private let TRUSTLIST_FILENAME = "trustlist"
    private let TRUSTLIST_KEY_ALIAS = "trustlist_key"
    private var cachedTrustlist : TrustList
    private let fileStorage : FileStorage
    
    init() {
        self.fileStorage = FileStorage()
        cachedTrustlist = TrustList(validFrom: 0, validUntil: 0, entries: [])
        self.loadCachedTrustlist()
    }
    
    func key(for keyId: Data, keyType: CertType, completionHandler: @escaping (Result<SecKey, ValidationError>)->()){
        if cachedTrustlist.isValid() {
            cachedKey(from: keyId, for: keyType, completionHandler)
            return
        }
        updateTrustlist { error in
            if let error = error {
                DDLogError("Cannot refresh trust list: \(error)")
            }
            self.cachedKey(from: keyId, for: keyType, completionHandler)
        }
    }
    
    func updateTrustlist(completionHandler: @escaping (ValidationError?)->()) {
        guard let url = URL(string: "\(CERT_SERVICE_URL)\(TRUST_LIST_PATH)") else {
            DDLogError("Cannot construct certificate query url.")
            completionHandler(.TRUST_SERVICE_ERROR(cause: "Cannot construct service url."))
            return
        }
        
        var request = URLRequest(url: url)
        request.addValue("application/octet-stream", forHTTPHeaderField: "Accept")
        URLSession.shared.dataTask(with: request) { body, response, error in
            guard error == nil,
                  let status = (response as? HTTPURLResponse)?.statusCode,
                  200 == status,
                  let body = body else {
                DDLogError("Cannot query trustlist service")
                completionHandler(.TRUST_SERVICE_ERROR(cause: "Cannot renew trustlist: \(error?.localizedDescription)"))
                return
            }
            guard self.refreshTrustlist(from: body) else {
                completionHandler(.TRUST_SERVICE_ERROR(cause: "Cannot create valid trustlist from response body"))
                return
            }
            completionHandler(nil)
        }.resume()
    }
    
    private func cachedKey(from keyId: Data, for keyType: CertType, _ completionHandler: @escaping (Result<SecKey, ValidationError>)->()) {
        guard let entry = cachedTrustlist.entry(for: keyId) else {
            completionHandler(.failure(.KEY_NOT_IN_TRUST_LIST))
            return
        }
        guard entry.isValid() else {
            completionHandler(.failure(.PUBLIC_KEY_EXPIRED))
            return
        }
        guard entry.isSuitable(for: keyType) else {
            completionHandler(.failure(.UNSUITABLE_PUBLIC_KEY_TYPE))
            return
        }
        guard let secKey = entry.publicKey else {
            completionHandler(.failure(.KEY_CREATION_ERROR))
            return
        }
        completionHandler(.success(secKey))
    }
    
    private func refreshTrustlist(from data: Data) -> Bool {
        guard let cose = Cose(from: data),
              let cbor = cose.payload.decodeBytestring(),
              let trustlist = try? CodableCBORDecoder().decode(TrustList.self, from: Data(cbor.encode())),
              trustlist.isValid() else {
            return false
        }
        self.cachedTrustlist = trustlist
        storeTrustlist()
        return true
    }
    
    private func storeTrustlist(){
        guard let trustlistData = try? JSONEncoder().encode(self.cachedTrustlist) else {
            DDLogError("Cannot encode trustlist for storing")
            return
        }
        CryptoService.createKeyAndEncrypt(data: trustlistData, with: self.TRUSTLIST_KEY_ALIAS, completionHandler: { result in
            switch result {
            case .success(let data):
                if !self.fileStorage.writeProtectedFileToDisk(fileData: data, with: self.TRUSTLIST_FILENAME) {
                    DDLogError("Cannot write trustlist to disk")
                }
            case .failure(let error): DDLogError(error)
            }
        })
    }
    
    private func loadCachedTrustlist(){
        if let trustlistData = fileStorage.loadProtectedFileFromDisk(with: TRUSTLIST_FILENAME) {
            CryptoService.decrypt(ciphertext: trustlistData, with: TRUSTLIST_KEY_ALIAS) { result in
                switch result {
                case .success(let plaintext):
                    if let trustlist = try? JSONDecoder().decode(TrustList.self, from: plaintext),
                       trustlist.isValid() {
                        self.cachedTrustlist = trustlist
                    }
                case .failure(let error): DDLogError("Cannot load cached trust list: \(error)")
                }
            }
        }
    }
}
