//
//  ValueSetService.swift
//  
//
//  Created by Martin Fitzka-Reichart on 14.07.21.
//

import Foundation
import CertLogic

public protocol ValueSetsService {
    func valueSets(completionHandler: @escaping (Swift.Result<[String:ValueSet], ValidationError>) -> ())
    func updateDataIfNecessary(completionHandler: @escaping (ValidationError?)->())
}

class DefaultValueSetsService : SignedDataService<ValueSetContainer>, ValueSetsService {
    private let VALUE_SETS_FILENAME = "valuesets"
    private let VALUE_SETS_KEY_ALIAS = "valuesets_key"
    private let VALUE_SETS_KEYCHAIN_ALIAS = "valuesets_keychain"
    private let LAST_UPDATE_KEY = "last_valuesets_update"

    init(dateService: DateService, valueSetsUrl: String, signatureUrl: String, trustAnchor: String) {
        super.init(dateService: dateService,
                   dataUrl: valueSetsUrl,
                   signatureUrl: signatureUrl,
                   trustAnchor: trustAnchor,
                   updateInterval: TimeInterval(1.hour * 24),
                   fileName: self.VALUE_SETS_FILENAME,
                   keyAlias: self.VALUE_SETS_KEY_ALIAS,
                   legacyKeychainAlias: self.VALUE_SETS_KEYCHAIN_ALIAS,
                   lastUpdateKey: self.LAST_UPDATE_KEY)
    }

    private func mappedValueSets() -> [String:ValueSet] {
        return cachedData.entries.reduce(into: [String:ValueSet]()) {
            guard let jsonData = $1.valueSet.data(using: .utf8) else { return }

            guard let valueSet = try? defaultDecoder.decode(ValueSet.self, from: jsonData) else { return }

            $0[$1.name] = valueSet
        }
    }

    func valueSets(completionHandler: @escaping (Swift.Result<[String:ValueSet], ValidationError>) -> ()) {
        updateDataIfNecessary { _ in
            completionHandler(.success(self.mappedValueSets()))
        }
    }
}
