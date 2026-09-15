//
//  AppConfiguration.swift
//  Taichi
//
//  Created by Toan Nguyen on 18/11/24.
//

import Foundation

enum AppConfiguration {
    static let appName = getConfigurationValue(by: .appName).unsafelyUnwrapped
    static let appEnv = getConfigurationValue(by: .appEnv).unsafelyUnwrapped
    static let appId = getConfigurationValue(by: .appId).unsafelyUnwrapped
    static let privacyUrl = getConfigurationValue(by: .privacyUrl).unsafelyUnwrapped
    static let termOfUseUrl = getConfigurationValue(by: .termOfUseUrl).unsafelyUnwrapped
    static let emailFeedback = getConfigurationValue(by: .emailFeedback).unsafelyUnwrapped
    static let adjustToken = getConfigurationValue(by: .adjustToken).unsafelyUnwrapped
}

private extension AppConfiguration {
    enum ConfigurationValue: String {
        case appName = "APP_NAME"
        case appEnv = "APP_ENV"
        case appId = "APP_ID"
        case privacyUrl = "PRIVACY_URL"
        case termOfUseUrl = "TERM_OF_USE_URL"
        case emailFeedback = "EMAIL_FEEDBACL"
        case adjustToken = "ADJUST_TOKEN"
    }

    static func getConfigurationValue(by key: ConfigurationValue) -> String? {
        (Bundle.main.infoDictionary?[key.rawValue] as? String)?
            .replacingOccurrences(of: "\\", with: "")
    }
}
