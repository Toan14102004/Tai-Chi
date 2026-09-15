//
//  Loadable.swift
//  Taichi
//
//  Created by Toan Nguyen on 19/11/24.
//

import Foundation
import SwiftUI

typealias LoadableSubject<Value> = Binding<Loadable<Value>>

enum Loadable<T> {
    case notRequested
    case isLoading(last: T?, cancelBag: CancelBag)
    case loaded(T)
    case failed(Error)

    var value: T? {
        switch self {
        case let .loaded(value): value
        case let .isLoading(last, _): last
        default: nil
        }
    }

    var error: Error? {
        switch self {
        case let .failed(error): error
        default: nil
        }
    }
}

extension Loadable {
    mutating func setIsLoading(cancelBag: CancelBag) {
        self = .isLoading(last: value, cancelBag: cancelBag)
    }

    mutating func cancelLoading() {
        switch self {
        case let .isLoading(last, cancelBag):
            cancelBag.cancel()
            if let last {
                self = .loaded(last)
            } else {
                let error = NSError(
                    domain: NSCocoaErrorDomain,
                    code: NSUserCancelledError,
                    userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("Canceled by user", comment: "")]
                )
                self = .failed(error)
            }
        default: break
        }
    }

    func map<V>(_ transform: (T) throws -> V) -> Loadable<V> {
        do {
            switch self {
            case .notRequested: return .notRequested
            case let .failed(error): return .failed(error)
            case let .isLoading(value, cancelBag):
                return try .isLoading(
                    last: value.map { try transform($0) },
                    cancelBag: cancelBag
                )
            case let .loaded(value):
                return try .loaded(transform(value))
            }
        } catch {
            return .failed(error)
        }
    }
}

protocol SomeOptional {
    associatedtype Wrapped
    func unwrap() throws -> Wrapped
}

struct ValueIsMissingError: Error {
    var localizedDescription: String {
        NSLocalizedString("Data is missing", comment: "")
    }
}

extension Optional: SomeOptional {
    func unwrap() throws -> Wrapped {
        switch self {
        case let .some(value): return value
        case .none: throw ValueIsMissingError()
        }
    }
}

extension Loadable where T: SomeOptional {
    func unwrap() -> Loadable<T.Wrapped> {
        map { try $0.unwrap() }
    }
}

extension Loadable: Equatable where T: Equatable {
    static func == (lhs: Loadable<T>, rhs: Loadable<T>) -> Bool {
        switch (lhs, rhs) {
        case (.notRequested, .notRequested): true
        case let (.isLoading(lhsV, lhsC), .isLoading(rhsV, rhsC)):
            lhsV == rhsV && lhsC.isEqual(to: rhsC)
        case let (.loaded(lhsV), .loaded(rhsV)): lhsV == rhsV
        case let (.failed(lhsE), .failed(rhsE)):
            lhsE.localizedDescription == rhsE.localizedDescription
        default: false
        }
    }
}
