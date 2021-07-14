//
//  BusinessRulesService.swift
//  
//
//  Created by Martin Fitzka-Reichart on 14.07.21.
//

import Foundation
import CertLogic

public protocol BusinessRulesService {
    func businessRules(completionHandler: @escaping (Swift.Result<[Rule], ValidationError>) -> ())
    func updateDataIfNecessary(completionHandler: @escaping (ValidationError?)->())
}

class DefaultBusinessRulesService : SignedDataService<BusinessRulesContainer>, BusinessRulesService {
    private let BUSINESS_RULES_FILENAME = "businessrules"
    private let BUSINESS_RULES_KEY_ALIAS = "businessrules_key"
    private let BUSINESS_RULES_KEYCHAIN_ALIAS = "businessrules_keychain"
    private let LAST_UPDATE_KEY = "last_businessrules_update"

    init(dateService: DateService, businessRulesUrl: String, signatureUrl: String, trustAnchor: String) {
        super.init(dateService: dateService,
                   dataUrl: businessRulesUrl,
                   signatureUrl: signatureUrl,
                   trustAnchor: trustAnchor,
                   updateInterval: TimeInterval(1.hour * 24),
                   fileName: self.BUSINESS_RULES_FILENAME,
                   keyAlias: self.BUSINESS_RULES_KEY_ALIAS,
                   legacyKeychainAlias: self.BUSINESS_RULES_KEYCHAIN_ALIAS,
                   lastUpdateKey: self.LAST_UPDATE_KEY)
    }

    private func parsedBusinessRules() -> [Rule] {
        return cachedData.entries.compactMap({
            guard let jsonData = $0.rule.data(using: .utf8) else { return nil }

            return try? defaultDecoder.decode(Rule.self, from: jsonData)
        })
    }

    func businessRules(completionHandler: @escaping (Swift.Result<[Rule], ValidationError>) -> ()) {
        updateDataIfNecessary { _ in
            self.cachedBusinessRules(completionHandler: completionHandler)
        }
    }

    private func cachedBusinessRules(completionHandler: @escaping (Swift.Result<[Rule], ValidationError>) -> ()) {
        completionHandler(.success(parsedBusinessRules()))
    }

}
