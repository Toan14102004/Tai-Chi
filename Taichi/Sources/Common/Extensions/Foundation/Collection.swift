//
//  Collection.swift
//  Taichi
//
//  Created by Toan Nguyen on 18/11/24.
//

import Foundation

extension Collection {
    func count(by key: KeyPath<Element, Bool>) -> Int {
        filter { $0[keyPath: key] }.count
    }

    func count(by key: KeyPath<Element, Int>) -> Int {
        reduce(0) { $0 + $1[keyPath: key] }
    }

    func count(_ counter: (Element) -> Int) -> Int {
        reduce(0) { $0 + counter($1) }
    }

    func filter(by key: KeyPath<Element, Bool>) -> [Element] {
        filter { $0[keyPath: key] }
    }
}

extension Array where Element: Equatable {
    var unique: [Element] {
        var result = [Element]()
        for element in self where !result.contains(element) {
            result.append(element)
        }
        return result
    }
}
