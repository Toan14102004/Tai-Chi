//
// Created by Shaban on 24/05/2021.
// Copyright (c) 2021 sha. All rights reserved.
//

import Foundation

/// A typealias for a closure that produces a string.
public typealias StringProducerClosure = () -> String

/// A typealias for a closure that handles validation change events.
public typealias OnValidationChange = (Validation) -> Void

/// A protocol representing a form validator.
public protocol Validatable {
    /// The type of the value being validated.
    associatedtype Value
    
    /// The value to validate, which can be set or retrieved and may be optional.
    var value: Value? { get set }

    /// Performs validation on the current value and returns the result.
    func validate() -> Validation

    /// A boolean indicating whether the value is empty.
    var isEmpty: Bool { get }

    /// A closure that produces a validation message.
    var message: StringProducerClosure { get }

    /// The root published whose value is validated.
    var publisher: ValidationPublisher! { get set }

    /// A subject used for manually triggering the validation.
    var subject: ValidationSubject { get set }

    /// This callback is called when a validation is triggered.
    /// Don't provide a closure because it's used internally.
    var onChanged: [OnValidationChange] { get set }

    /// Calls the subject to manually trigger validation.
    func triggerValidation(isDisabled: Bool, shouldShowError: Bool)
    
    /// Notifies registered observers when the validation value changes.
    func valueChanged(_ value: Validation)
    
    /// Registers a callback to observe changes to the validation value.
    mutating func observeChange(_ callback: @escaping OnValidationChange)
}

public extension Validatable {
    /// Default implementation of triggerValidation().
    func triggerValidation(isDisabled: Bool = false, shouldShowError: Bool = true) {
        guard !isDisabled else {
            subject.send(.success)
            return
        }
        let value = validate()
        if shouldShowError {
            subject.send(value)
        } else {
            subject.send(.success)
        }
        valueChanged(value)
    }

    /// Notifies registered observers when the validation value changes.
    func valueChanged(_ value: Validation) {
        onChanged.forEach { item in
            item(value)
        }
    }

    /// Registers a callback to observe changes to the validation value.
    mutating func observeChange(_ callback: @escaping OnValidationChange) {
        onChanged.append(callback)
    }
}

public extension Validatable {
    /// A boolean indicating whether the value is empty.
    var isEmpty: Bool {
        guard let value else {
            return true
        }
        if let string = value as? String {
            return string.isEmpty
        }
        return false
    }
}

///// A protocol representing a form validator.
public protocol StringValidator: Validatable {
    /// The value type of this validator
    var value: String? { get set }
}
