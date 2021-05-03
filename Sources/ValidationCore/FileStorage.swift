//
//  File.swift
//  
//
//  Created by Dominik Mocher on 22.04.21.
//

import Foundation
import CocoaLumberjackSwift

public struct FileStorage {
    private let STORAGE_DIR : String
    private let fm = FileManager.default
    
    public init(){
        self.init(storageDir: "")
    }
    
    public init(storageDir: String) {
        STORAGE_DIR = storageDir
    }
    
    public func writeProtectedFileToDisk(fileData: Data, with filename: String) -> Bool {
        guard var filepath = fileUrl(from: filename) else {
            return false
        }
        do {
            try fileData.write(to: filepath, options: .completeFileProtection)
            try filepath.excludeFromBackup()
        } catch (let error) {
            DDLogError("Cannot write to file \(filepath): \(error)")
            return false
        }
        return true
    }
    
    public func loadProtectedFileFromDisk(with filename: String) -> Data? {
        guard let filepath = certDirPath?.appending("/\(filename)") else {
            return nil
        }
        return fm.contents(atPath: filepath)
    }
    
    public func deleteFile(with filename: String){
        if let filepath = certDirPath?.appending("/\(filename)") {
            try? fm.removeItem(atPath: filepath)
        }
    }
    
    private var certDirPath : String? {
        get {
            guard let certDirPath = fm.appSupportDirectory?.appending("/\(STORAGE_DIR)") else {
                return nil
            }
            fm.createDirIfNotExists(certDirPath)
            return certDirPath
        }
    }
    
    private func fileUrl(from filename: String) -> URL? {
        guard let certDirPath = certDirPath else {
            return nil
        }
        return URL(fileURLWithPath: certDirPath.appending("/\(filename)"))
    }
}

// MARK: - Extensions
fileprivate extension FileManager {
    var appSupportDirectory : String? {
        return NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first
    }
    
    func createDirIfNotExists(_ dir: String) {
        if !fileExists(atPath: dir) {
            do {
                try createDirectory(atPath: dir, withIntermediateDirectories: true, attributes: nil)
            }
            catch (let e){
                DDLogError(e)
            }
        }
    }
}

fileprivate extension URL {
    mutating func excludeFromBackup() throws {
        var fileValues = URLResourceValues()
        fileValues.isExcludedFromBackup = true
        try setResourceValues(fileValues)
    }
}
