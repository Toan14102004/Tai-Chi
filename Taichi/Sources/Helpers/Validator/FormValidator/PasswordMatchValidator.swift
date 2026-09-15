//
// Created by Shaban on 24/05/2021.
// Copyright (c) 2021 sha. All rights reserved.
//

import Foundation

public struct ValidatedPassword: Equatable {
    let password: String
    let type: Int

    public init(password: String, type: Int) {
        self.password = password
        self.type = type
    }
}

/// A structure that holds two password strings for comparison and validation.
public struct PasswordInfo {
    let pass1: String
    let pass2: String
}

/// A typealias for a closure that produces password validation messages.
public typealias PasswordMatchingMessage = () -> (empty: String, notMatching: String, invalidPattern: String)

public class PasswordMatchValidator: Validatable {
    public var publisher: ValidationPublisher!
    public var subject: ValidationSubject = .init()
    public var onChanged: [OnValidationChange] = []

    private let firstPassword: StringProducerClosure
    private let secondPassword: StringProducerClosure
    private let pattern: NSRegularExpression?

    public let message: StringProducerClosure = { "" }
    public let validationMessage: PasswordMatchingMessage

    public var value: ValidatedPassword? = ValidatedPassword(password: "", type: 0)

    public init(firstPassword: @autoclosure @escaping StringProducerClosure,
                secondPassword: @autoclosure @escaping StringProducerClosure,
                pattern: NSRegularExpression? = nil,
                message: @autoclosure @escaping PasswordMatchingMessage) {
        self.firstPassword = firstPassword
        self.secondPassword = secondPassword
        self.pattern = pattern
        validationMessage = message
    }

    public func validate() -> Validation {
        if let matchingError = validateMatching() {
            return .failure(message: matchingError)
        }
        if let patternError = validatePattern() {
            return .failure(message: patternError)
        }
        return .success
    }

    private func validateMatching() -> String? {
        guard let value else {
            return nil
        }
        let password1 = value.type == 0 ? value.password : firstPassword()
        let password2 = value.type == 1 ? value.password : secondPassword()

        if password1.isEmpty, password2.isEmpty {
            return validationMessage().empty
        }

        return password1 == password2 ? nil : validationMessage().notMatching
    }

    private func validatePattern() -> String? {
        guard let value else {
            return nil
        }
        guard let pattern = pattern else {
            return nil
        }
        let patternValidator = PasswordValidator(pattern: pattern, message: self.validationMessage().invalidPattern)
        patternValidator.value = value.password
        return patternValidator.validate().isSuccess ? nil : validationMessage().invalidPattern
    }

}
