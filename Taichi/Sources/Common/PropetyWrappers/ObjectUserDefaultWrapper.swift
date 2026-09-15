//
//  ObjectUserDefaultWrapper.swift
//  Taichi
//
//  Created by Toan Nguyen on 18/11/24.
//

import Foundation

@propertyWrapper
struct ObjectUserDefaultWrapper<T: Codable> {
    let key: String
    let defaultValue: T
    let userDefaults: UserDefaults = .standard

    var wrappedValue: T {
        get {
            let decoder = JSONDecoder()
            guard let data = userDefaults.data(forKey: key), let object = try? decoder.decode(T.self, from: data) else {
                return defaultValue
            }
            return object
        }
        set {
            if let optional = newValue as? AnyOptional, optional.isNil {
                userDefaults.removeObject(forKey: key)
                return
            }
            let encoder = JSONEncoder()
            guard let encoded = try? encoder.encode(newValue) else { return }
            userDefaults.set(encoded, forKey: key)
        }
    }
}
