//
//  KeychainWrapper.swift
//  Taichi
//
//  Created by Toan Nguyen on 8/9/25.
//

import Foundation

@propertyWrapper
struct KeychainWrapper<T: Equatable> {
    let key: String
    let defaultValue: T
    let keychain = KeychainService.shared.keychain

    var wrappedValue: T {
        get {
            if let stringValue = try? keychain.get(key) {
                if T.self == Bool.self {
                    return ((stringValue as NSString).boolValue as? T) ?? defaultValue
                } else if T.self == Int.self {
                    return (Int(stringValue) as? T) ?? defaultValue
                } else if T.self == Double.self {
                    return (Double(stringValue) as? T) ?? defaultValue
                } else {
                    return (stringValue as? T) ?? defaultValue
                }
            }
            return defaultValue
        }
        set {
            if let optional = newValue as? AnyOptional, optional.isNil {
                try? keychain.remove(key)
                return
            }
            try? keychain.set("\(newValue)", key: key)
        }
    }
}
