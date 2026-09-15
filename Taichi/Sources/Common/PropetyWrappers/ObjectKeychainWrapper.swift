//
//  ObjectKeychainWrapper.swift
//  Taichi
//
//  Created by Toan Nguyen on 8/9/25.
//

import Foundation

@propertyWrapper
struct ObjectKeychainWrapper<T: Codable> {
    let key: String
    let defaultValue: T
    let keychain = KeychainService.shared.keychain

    var wrappedValue: T {
        get {
            guard let data = try? keychain.getData(key) else {
                return defaultValue
            }
            let decoder = JSONDecoder()
            guard let object = try? decoder.decode(T.self, from: data) else {
                return defaultValue
            }
            return object
        }
        set {
            if let optional = newValue as? AnyOptional, optional.isNil {
                try? keychain.remove(key)
                return
            }
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(newValue) {
                try? keychain.set(encoded, key: key)
            }
        }
    }
}
