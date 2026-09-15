//
//  Optional.swift
//  Taichi
//
//  Created by Toan Nguyen on 18/11/24.
//

import Foundation

protocol AnyOptional {
    var isNil: Bool { get }
}

extension Optional: AnyOptional {
    var isNil: Bool { self == nil }
}

protocol StringType {
    var isEmpty: Bool { get }
}

extension String: StringType {}

extension Optional where Wrapped: StringType {
    var isNullOrEmpty: Bool {
        self?.isEmpty ?? true
    }
}

extension Double? {
    func toStringHoursAndMinutes(format _: String = "%02d") -> String {
        Double.convertHourAndMinute(time: self ?? 0)
    }
}

extension Int? {
    var isNullOrZero: Bool {
        guard let self else { return true }
        return self == 0
    }
}

// MARK: - Optional String functions

extension String? {
    func toNoAvailableIfEmpty() -> String? {
        isNullOrEmpty ? "N/A" : self
    }

    var catchNilAndReturnEmpty: String {
        self ?? ""
    }
}

// MARK: - Optional Boolean function

extension Bool? {
    var unWrappedWithTrueDefault: Bool {
        self ?? true
    }

    var unWrappedWithFalseDefault: Bool {
        self ?? false
    }
}

// MARK: - Optional Int functions

extension Int? {
    func toString() -> String? {
        if let value = self {
            return "\(value)"
        }
        return nil
    }

    var unwrapWithDefaultZero: Int {
        self ?? 0
    }
}
