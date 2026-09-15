//
//  UserDefaultWrapper.swift
//  Taichi
//
//  Created by Toan Nguyen on 18/11/24.
//

import Foundation

@propertyWrapper
struct UserDefaultWrapper<T: Equatable> {
    let key: String
    let defaultValue: T
    let userDefaults: UserDefaults = .standard

    var wrappedValue: T {
        get {
            userDefaults.object(forKey: key) as? T ?? defaultValue
        }

        set {
            if let optional = newValue as? AnyOptional, optional.isNil {
                userDefaults.removeObject(forKey: key)
                return
            }
            userDefaults.set(newValue, forKey: key)
        }
    }
}
