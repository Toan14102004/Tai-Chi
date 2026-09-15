//
// Created by Shaban on 14/05/2023.
// Copyright (c) 2023 sha. All rights reserved.
//

import Combine
import Foundation

/// A property wrapper that manages a date value for use in form fields with reactive updates.
///
/// `DateFormField` encapsulates a `Date` value, providing a reactive interface through Combine's
/// `@Published` property wrapper and exposing the value as both a wrapped value and a publisher.
/// It is designed to simplify form field management in reactive applications.
///
/// - Note: This type integrates with the Combine framework for reactive programming.
@propertyWrapper
public class DateFormField {
    @Published
    private var value: Date
    private let message: String

    /// The projected value, providing a publisher for the date value.
    public var projectedValue: AnyPublisher<Date, Never> {
        $value.eraseToAnyPublisher()
    }

    /// The wrapped value of the form field.
    public var wrappedValue: Date {
        get {
            value
        }
        set {
            value = newValue
        }
    }

    /// Initializes the form field with a wrapped date value and message.
    ///
    /// - Parameters:
    ///   - value: The initial date value to be wrapped.
    ///   - message: A string message, typically used to describe validation errors.
    public init(wrappedValue value: Date, message: String) {
        self.value = value
        self.message = message
    }

    /// Initializes the form field with an initial date value and message.
    /// - Parameters:
    ///   - value: The initial date value for the form field.
    ///   - message: A string message, typically used to describe validation errors.
    public init(initialValue value: Date, message: String) {
        self.value = value
        self.message = message
    }

    /// Configures and returns a validation container for the date value.
    /// - Parameters:
    ///   - manager: The `FormManager` instance responsible for coordinating validation.
    ///   - before: The latest acceptable date (defaults to `.distantFuture`).
    ///   - after: The earliest acceptable date (defaults to `.distantPast`).
    ///   - disableValidation: A closure that determines whether validation should be skipped (defaults to always false).
    ///   - onValidate: An optional closure called when validation occurs.
    /// - Returns: A `ValidationContainer` configured with the specified validation rules and publisher.
    public func validation(
            manager: FormManager,
            before: Date = .distantFuture,
            after: Date = .distantPast,
            disableValidation: @escaping DisableValidationClosure = {
                false
            },
            onValidate: OnValidate? = nil
    ) -> ValidationContainer {
        let validator = DateValidator(
                before: before,
                after: after,
                message: self.message)
        let pub: AnyPublisher<Date, Never> = $value.eraseToAnyPublisher()
        return ValidationFactory.create(
                manager: manager,
                validator: validator,
                for: pub,
                disableValidation: disableValidation,
                onValidate: onValidate)
    }
}
