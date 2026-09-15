//
// Created by Shaban on 14/05/2023.
// Copyright (c) 2023 sha. All rights reserved.
//

import Combine

/// A property wrapper that manages a form field's value and validation state.
///
/// `FormField` combines a value with validation logic, providing a convenient way to handle
/// form inputs in a reactive manner. It uses Combine's `CurrentValueSubject` to maintain
/// and broadcast the current value.
///
/// - Type Parameters:
///   - `Value`: The type of value stored in the form field, must conform to `Equatable`.
///   - `Validator`: The type responsible for validating the value, must conform to `Validatable`
///                  and have a matching `Value` type.
@propertyWrapper
public class FormField<Value: Equatable, Validator: Validatable> where Value == Validator.Value {
    
    private var subject: CurrentValueSubject<Value, Never>
    private let validator: Validator

    /// The wrapped value of the form field.
    public var wrappedValue: Value {
        get {
            subject.value
        }
        set {
            subject.send(newValue)
        }
    }

    /// Initializes a `FormField` with an initial value and a validator factory closure.
    /// - Parameters:
    ///   - wrappedValue: The initial value of the form field.
    ///   - validator: A closure that returns a `Validator` instance when called.
    public init(wrappedValue value: Value, validator: () -> Validator) {
        self.subject = CurrentValueSubject(value)
        self.validator = validator()
    }

    /// Initializes a `FormField` with an initial value and a pre-constructed validator.
    /// - Parameters:
    ///   - wrappedValue: The initial value of the form field.
    ///   - validator: The `Validator` instance to use for validating the form field’s value.
    public init(wrappedValue value: Value, validator: Validator) {
        self.subject = CurrentValueSubject(value)
        self.validator = validator
    }

    /// Initializes a `FormField` with an initial value and a validator factory closure.
    /// - Parameters:
    ///   - initialValue: The initial value of the form field.
    ///   - validator: A closure that returns a `Validator` instance when called.
    public init(initialValue value: Value, validator: () -> Validator) {
        self.subject = CurrentValueSubject(value)
        self.validator = validator()
    }
    
    /// A static subscript for accessing and modifying the wrapped value of a `FormField` within an enclosing instance.
    /// - Parameters:
    ///   - _enclosingInstance: The instance of the enclosing type that contains the `FormField` property.
    ///   - wrapped: A key path to the property being wrapped by `FormField`, representing the value.
    ///   - storage: A key path to the `FormField` instance itself, representing the storage of the property wrapper.
    /// - Returns: The current value of the wrapped property.
    /// - Note: When setting a new value, if the enclosing instance conforms to `ObservableObject`, it will
    ///   trigger an `objectWillChange` notification before updating the value.
    public static subscript<EnclosingSelf>(
        _enclosingInstance object: EnclosingSelf,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<EnclosingSelf, Value>,
        storage storageKeyPath: ReferenceWritableKeyPath<EnclosingSelf, FormField>
    ) -> Value {
        get { object[keyPath: storageKeyPath].wrappedValue }
        set {
            if let observableObject = object as? (any ObservableObject),
               let objectWillChange = (observableObject.objectWillChange as any Publisher) as? ObservableObjectPublisher {
                objectWillChange.send()
            }
            object[keyPath: storageKeyPath].wrappedValue = newValue
        }
    }
    
    /// Creates a validation container for the form field’s value using a specified form manager.
    /// - Parameters:
    ///   - manager: The `FormManager` instance responsible for coordinating validation across multiple fields.
    ///   - disableValidation: An optional closure that determines whether validation should be disabled for this field.
    ///     Defaults to a closure returning `false` (validation enabled).
    ///   - onValidate: An optional closure to execute when validation occurs. Defaults to `nil`.
    /// - Returns: A `ValidationContainer` that encapsulates the validation logic and state for this field.
    public func validation(
            manager: FormManager,
            disableValidation: @escaping DisableValidationClosure = {
                false
            },
            onValidate: OnValidate? = nil
    ) -> ValidationContainer {
        let pub: AnyPublisher<Value, Never> = subject.eraseToAnyPublisher()
        return ValidationFactory.create(
                manager: manager,
                validator: validator,
                for: pub,
                disableValidation: disableValidation,
                onValidate: onValidate)
    }
}

public extension FormField where Validator == InlineValidator<Value> {
    
    /// A convenience initializer for creating a `FormField` with an inline validation closure.
    /// - Parameters:
    ///   - wrappedValue: The initial value of the form field.
    ///   - inlineValidator: A closure that takes a `Value` and returns an optional `String`.
    ///     The returned string represents a validation error message if present, or `nil` if
    ///     the value is valid.
    convenience init(wrappedValue value: Value, inlineValidator: @escaping (Value) -> String?) {
        self.init(wrappedValue: value, validator: InlineValidator(condition: inlineValidator))
    }

}
