//
//  CryptoService.swift
//  
//
//  Created by Dominik Mocher on 20.04.21.
//

import Foundation
import CryptoKit
import LocalAuthentication
import Security
import CocoaLumberjackSwift

public struct CryptoService {
    
    public static func generateSymmetricKey(for alias: String, completionHandler : @escaping (ValidationError?)->()) throws {
        authenticate() { authContext, error in
            guard error == nil, let authContext = authContext else {
                completionHandler(.KEYSTORE_ERROR(cause: "Authentication failed"))
                return
            }
            guard let _ = createKey(for: alias, with: authContext) else {
                completionHandler(.KEYSTORE_ERROR(cause: "Cannot create key"))
                return
            }
            completionHandler(nil)
        }
    }
    
    public static func createKeyAndEncrypt(data: Data, with keyAlias: String, completionHandler : @escaping (Result<Data, ValidationError>)->()) {
        let authContext = LAContext()
        guard let key = createKey(for: keyAlias, with: authContext) else {
            completionHandler(.failure(.KEYSTORE_ERROR(cause: "Cannot create key")))
            return
        }
        
        guard let sealed = try? AES.GCM.seal(data, using: key).combined else {
            completionHandler(.failure(.KEYSTORE_ERROR(cause: "Cannot encrypt data")))
            return
        }
        completionHandler(.success(sealed))
    }
    
    public static func decrypt(ciphertext: Data, with keyAlias: String, completionHandler : @escaping (Result<Data, ValidationError>)->()) {
        guard let key = try? loadKey(alias: keyAlias) else {
            completionHandler(.failure(.KEYSTORE_ERROR(cause: "Cannot retrieve key from keychain")))
            return
        }
        
        guard let sealed = try? AES.GCM.SealedBox(combined: ciphertext),
              let opened = try? AES.GCM.open(sealed, using: key) else {
            completionHandler(.failure(.KEYSTORE_ERROR(cause: "Cannot decrypt data")))
            return
        }
        completionHandler(.success(opened))
    }
    
    private static func authenticate(_ completionHandler: @escaping (LAContext?, Error?)->()) {
        let context = LAContext()
        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Unlock encryption keys") { success, error in
            guard success, error == nil else {
                completionHandler(nil, error)
                return
            }
            completionHandler(context, nil)
        }
    }
    
    private static func createKey(for alias: String, with context: LAContext) -> SymmetricKey? {
        clearKey(for: alias)
        let key = SymmetricKey(size: .bits256)
        guard nil != (try? storeKey(key, alias: alias, context: context)) else {
            return nil
        }
        return key
    }
    
    private static func storeKey<T: GenericPasswordConvertible>(_ key: T, alias: String, context: LAContext) throws {
        guard let accessFlags = SecAccessControlCreateWithFlags(
                kCFAllocatorDefault,
                kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
                [],
                nil) else {
            throw ValidationError.KEYSTORE_ERROR(cause: "Cannot create access flags.")
        }
        let query = [kSecClass: kSecClassGenericPassword,
                     kSecAttrLabel: alias,
                     kSecAttrAccessControl: accessFlags,
                     kSecValueData: key.rawRepresentation] as [String: Any]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw ValidationError.KEYSTORE_ERROR(cause: "Cannot add key to keychain: \(status)")
        }
    }
    
    private static func loadKey(alias: String) throws -> SymmetricKey? {
        let query = [kSecClass: kSecClassGenericPassword,
                     kSecAttrLabel: alias,
                     kSecReturnData: true] as [String: Any]
        
        var item: CFTypeRef?
        switch SecItemCopyMatching(query as CFDictionary, &item) {
        case errSecSuccess:
            guard let data = item as? Data else {
                return nil
            }
            return try SymmetricKey(rawRepresentation: data)
        case errSecItemNotFound: return nil
        case let status: throw ValidationError.KEYSTORE_ERROR(cause: "Cannot retrieve key from keychain: \(status)")
        }
    }
    
    private static func clearKey(for alias: String) {
        let query = [kSecClass: kSecClassGenericPassword,
                     kSecAttrLabel: alias
        ] as [String: Any]
        SecItemDelete(query as CFDictionary)
    }
    
    public static func clearKeys(){
        let query = [kSecClass: kSecClassGenericPassword] as [String: Any]
        SecItemDelete(query as CFDictionary)
    }
}

// MARK: - Extensions

/// From https://developer.apple.com/documentation/cryptokit/storing_cryptokit_keys_in_the_keychain
protocol GenericPasswordConvertible: CustomStringConvertible {
    init<D>(rawRepresentation data: D) throws where D: ContiguousBytes
    
    var rawRepresentation: Data { get }
}

extension SymmetricKey: GenericPasswordConvertible {
    public var description: String {
        return "SymmetricKey"
    }
    
    init<D>(rawRepresentation data: D) throws where D: ContiguousBytes {
        self.init(data: data)
    }
    
    var rawRepresentation: Data {
        return self.withUnsafeBytes( { Data($0) })
    }
}
