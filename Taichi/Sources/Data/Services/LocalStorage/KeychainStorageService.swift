//
//  KeychainStorageService.swift
//  Taichi
//
//  Created by Toan Nguyen on 8/9/25.
//

import Foundation
import KeychainAccess

class KeychainService {
    static let shared = KeychainService()

    let keychain: Keychain

    private init() {
        keychain = Keychain(service: Bundle.main.bundleIdentifier ?? "com.limgrow.taichi")
    }
}

protocol KeychainServiceProtocol: AnyObject {
    var adsEnabled: Bool { get set }
    // Metadata for daily reset
    var featureConfigLastSetDate: String { get set }
    // Language preference
    var currentLanguageCode: String { get set }
    
    // Feature limits
    var freeCaptureLimit: Int { get set }
    var freeCaptureUsedCount: Int { get set }
    var countIdentityScan: Int { get set }
}

private enum Keys {
    static let adsEnabled = "ads_enabled"
    static let featureConfigLastSetDate = "feature_config_last_set_date"
    static let currentLanguageCode = "current_language_code"
    static let freeCaptureLimit = "free_capture_limit"
    static let freeCaptureUsedCount = "free_capture_used_count"
    static let countIdentityScan = "count_identity_scan"
}

class KeychainStorage: KeychainServiceProtocol {
    static let shared = KeychainStorage()

    // MARK: - IAP Configurations
    @KeychainWrapper(key: Keys.adsEnabled, defaultValue: true)
    var adsEnabled: Bool

    // MARK: - Language Preference
    @KeychainWrapper(key: Keys.featureConfigLastSetDate, defaultValue: "")
    var featureConfigLastSetDate: String

    @KeychainWrapper(key: Keys.currentLanguageCode, defaultValue: "en-US")
    var currentLanguageCode: String
    
    // MARK: - Feature Limits
    @KeychainWrapper(key: Keys.freeCaptureLimit, defaultValue: 5)
    var freeCaptureLimit: Int
    
    @KeychainWrapper(key: Keys.freeCaptureUsedCount, defaultValue: 0)
    var freeCaptureUsedCount: Int

    @KeychainWrapper(key: Keys.countIdentityScan, defaultValue: 0)
    var countIdentityScan: Int
}
