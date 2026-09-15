//
// Created by Shaban on 14/05/2023.
// Copyright (c) 2023 sha. All rights reserved.
//

import Combine
import Foundation

/// A property wrapper that manages a password input field with observable value changes.
///
/// `PasswordFormField` encapsulates a string value representing a password input and provides
/// a publisher for observing changes to that value. It is designed to be used as a
/// `@propertyWrapper` to simplify password field state management in SwiftUI or Combine-based
/// applications.
@propertyWrapper
public class PasswordFormField {
    @Published
    private var value: String
    private let message: PasswordMatchingMessage

    /// A publisher that emits the current password value whenever it changes.
    public var projectedValue: AnyPublisher<String, Never> {
        $value.eraseToAnyPublisher()
    }

    /// The wrapped value of the password field.
    public var wrappedValue: String {
        get {
            value
        }
        set {
            value = newValue
        }
    }

    /// Initializes a new instance with a wrapped value and a password matching message.
    ///
    /// - Parameters:
    ///   - wrappedValue: The initial string value.
    ///   - message: A closure that returns a password matching message.
    public init(wrappedValue value: String,
                message: @escaping @autoclosure PasswordMatchingMessage) {
        self.value = value
        self.message = message
    }

    /// Initializes a new instance with an initial value and a password matching message.
    ///
    /// - Parameters:
    ///   - initialValue: The initial string value.
    ///   - message: A closure that returns a password matching message.
    public init(initialValue value: String,
                message: @escaping @autoclosure PasswordMatchingMessage) {
        self.value = value
        self.message = message
    }

    /// Creates a `ValidationContainer` for password matching validation.
    ///
    /// - Parameters:
    ///   - manager: The `FormManager` responsible for handling form validation.
    ///   - other: The `PasswordFormField` to compare against.
    ///   - pattern: An optional `NSRegularExpression` pattern for additional password validation.
    ///   - disableValidation: A closure that determines whether validation should be disabled.
    ///   - onValidate: An optional validation callback that gets triggered when validation occurs.
    /// - Returns: A `ValidationContainer` that manages the validation process.
    public func validation(
            manager: FormManager,
            other: PasswordFormField,
            pattern: NSRegularExpression? = nil,
            disableValidation: @escaping DisableValidationClosure = {
                false
            },
            onValidate: OnValidate? = nil
    ) -> ValidationContainer {
        let pub = $value.eraseToAnyPublisher()
            .map {
                ValidatedPassword(password: $0, type: 0)
            }
        
        let pub2 = other.projectedValue.map {
            ValidatedPassword(password: $0, type: 1)
        }
        
        let merged = pub.merge(with: pub2)
            .dropFirst()
            .eraseToAnyPublisher()
        
        let validator = PasswordMatchValidator(
            firstPassword: self.value,
            secondPassword: other.value,
            pattern: pattern,
            message: self.message())
        return ValidationFactory.create(
            manager: manager,
            validator: validator,
            for: merged,
            disableValidation: disableValidation,
            onValidate: onValidate)
    }
}
