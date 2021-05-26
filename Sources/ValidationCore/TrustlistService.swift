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
    func updateTrustlistIfNecessary(completionHandler: @escaping (ValidationError?)->())
}

class DefaultTrustlistService : TrustlistService {
    private let CERT_SERVICE_URL = "https://dgc.a-sit.at/ehn/cert/"
    private let TRUST_LIST_PATH = "listv2"
    private let SIGNATURE_PATH = "sigv2"
    private let TRUSTLIST_FILENAME = "trustlist"
    private let TRUSTLIST_KEY_ALIAS = "trustlist_key"
    private let dateService : DateService
    private var cachedTrustlist : TrustList
    private let fileStorage : FileStorage
    private let trustlistAnchor = """
    MIIBJTCBy6ADAgECAgUAwvEVkzAKBggqhkjOPQQDAjAQMQ4wDAYDVQQDDAVFQy1N
    ZTAeFw0yMTA0MjMxMTI3NDhaFw0yMTA1MjMxMTI3NDhaMBAxDjAMBgNVBAMMBUVD
    LU1lMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE/OV5UfYrtE140ztF9jOgnux1
    oyNO8Bss4377E/kDhp9EzFZdsgaztfT+wvA29b7rSb2EsHJrr8aQdn3/1ynte6MS
    MBAwDgYDVR0PAQH/BAQDAgWgMAoGCCqGSM49BAMCA0kAMEYCIQC51XwstjIBH10S
    N701EnxWGK3gIgPaUgBN+ljZAs76zQIhAODq4TJ2qAPpFc1FIUOvvlycGJ6QVxNX
    EkhRcgdlVfUb
    """.replacingOccurrences(of: "\n", with: "")
    
    
    init(dateService: DateService) {
        self.fileStorage = FileStorage()
        cachedTrustlist = TrustList()
        self.dateService = dateService
        self.loadCachedTrustlist()
    }
    
    public func key(for keyId: Data, keyType: CertType, completionHandler: @escaping (Result<SecKey, ValidationError>)->()){
        updateTrustlistIfNecessary { error in
            if let error = error {
                DDLogError("Cannot refresh trust list: \(error)")
            }
            self.cachedKey(from: keyId, for: keyType, completionHandler)
        }
    }
    
    public func updateTrustlistIfNecessary(completionHandler: @escaping (ValidationError?)->()) {
        updateDetachedSignature() { result in
            switch result {
            case .success(let hash):
                if hash != self.cachedTrustlist.hash {
                    self.updateTrustlist(for: hash, completionHandler)
                    return
                }
                completionHandler(nil)
            case .failure(let error):
                completionHandler(error)
            }
       }
    }
    
    private func updateTrustlist(for hash: Data, _ completionHandler: @escaping (ValidationError?)->()) {
        guard let request = self.defaultRequest(to: self.TRUST_LIST_PATH) else {
            completionHandler(.TRUST_SERVICE_ERROR(cause: "Cannot create request to trustlist service."))
            return
        }
        
        URLSession.shared.dataTask(with: request) { body, response, error in
            guard self.isResponseValid(response, error), let body = body else {
                DDLogError("Cannot query trustlist service")
                completionHandler(.TRUST_SERVICE_ERROR(cause: "Cannot renew trustlist: \(error?.localizedDescription ?? "")"))
                return
            }
            guard self.refreshTrustlist(from: body, for: hash) else {
                completionHandler(.TRUST_SERVICE_ERROR(cause: "Cannot create valid trustlist from response body"))
                return
            }
            completionHandler(nil)
        }.resume()
    }
    
    private func updateDetachedSignature(completionHandler: @escaping (Result<Data, ValidationError>)->()) {
        guard let request = defaultRequest(to: SIGNATURE_PATH) else {
            completionHandler(.failure(.TRUST_SERVICE_ERROR(cause: "Cannot create request to trustlist service.")))
            return
        }
        
        URLSession.shared.dataTask(with: request) { body, response, error in
            guard self.isResponseValid(response, error), let body = body else {
                completionHandler(.failure(.TRUST_SERVICE_ERROR(cause: "Error in trustlist service response: \(error?.localizedDescription ?? "")")))
                return
            }
            guard let cose = Cose(from: body),
                  let trustAnchorKey = self.trustAnchorKey(),
                  cose.hasValidSignature(for: trustAnchorKey) else {
                completionHandler(.failure(.TRUST_SERVICE_ERROR(cause: "Invalid COSE in trustlist service response.")))
                return
            }
            guard let cwt = CWT(from: cose.payload),
                  cwt.isValid(using: self.dateService),
                  let trustlistHash = cwt.sub else {
                completionHandler(.failure(.TRUST_SERVICE_ERROR(cause: "Invalid CWT in trustlist service response.")))
                return
            }
            completionHandler(.success(trustlistHash))
        }.resume()
    }
    
    private func defaultRequest(to path: String) -> URLRequest? {
        guard let url = URL(string: "\(CERT_SERVICE_URL)\(path)") else {
            return nil
        }
        var request = URLRequest(url: url)
        request.addValue("application/octet-stream", forHTTPHeaderField: "Accept")
        return request
    }
    
    private func isResponseValid(_ response: URLResponse?, _ error: Error?) -> Bool {
        guard error == nil,
              let status = (response as? HTTPURLResponse)?.statusCode,
              200 == status else {
            return false
        }
        return true
    }
    
    private func cachedKey(from keyId: Data, for keyType: CertType, _ completionHandler: @escaping (Result<SecKey, ValidationError>)->()) {
        guard let entry = cachedTrustlist.entry(for: keyId) else {
            completionHandler(.failure(.KEY_NOT_IN_TRUST_LIST))
            return
        }
        guard entry.isValid(for: dateService) else {
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
    
    private func refreshTrustlist(from data: Data, for hash: Data) -> Bool {
        guard let cbor = try? CBORDecoder(input: data.bytes).decodeItem(),
            var trustlist = try? CodableCBORDecoder().decode(TrustList.self, from: cbor.asData()) else {
            return false
        }
        trustlist.hash = hash
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
                    if let trustlist = try? JSONDecoder().decode(TrustList.self, from: plaintext) {
                        self.cachedTrustlist = trustlist
                    }
                case .failure(let error): DDLogError("Cannot load cached trust list: \(error)")
                }
            }
        }
    }
    
    private func trustAnchorKey() -> SecKey? {
        guard let certData = Data(base64Encoded: trustlistAnchor),
              let certificate = SecCertificateCreateWithData(nil, certData as CFData),
              let secKey = SecCertificateCopyKey(certificate) else {
            return nil
        }
        return secKey
    }
}
