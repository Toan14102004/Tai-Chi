//
//  Array.swift
//  Taichi
//
//  Created by Toan Nguyen on 8/9/25.
//

import Foundation

extension Array where Element: Identifiable {
    func hasUniqueIDs() -> Bool {
        var uniqueElements: [Element.ID] = []
        for el in self {
            if !uniqueElements.contains(el.id) {
                uniqueElements.append(el.id)
            } else {
                return false
            }
        }
        return true
    }
}

public extension Array {
    var isNotEmpty: Bool {
        !isEmpty
    }
}
