//
//  Selectable.swift
//  Taichi
//
//  Created by Toan Nguyen on 16/3/25.
//

import Foundation

protocol Selectable {
    var selected: Bool { get set }
}

extension Collection where Element: Selectable {
    func countSelected() -> Int {
        filter(\.selected).count
    }

    var selected: [Self.Element] { filter(\.selected) }
    var nonselected: [Self.Element] { filter { !$0.selected } }

    var isAllSelected: Bool {
        allSatisfy(\.selected)
    }
}

extension RangeReplaceableCollection where Element: Selectable {
    mutating func removeSelected() {
        self = filter { !$0.selected }
    }
}

/// For dictionary
extension Collection {
    func countSelected<Key, E: Selectable>() -> Int where Element == (key: Key, value: [E]) {
        flatMap(\.value).filter(\.selected).count
    }
}

extension Dictionary {
    mutating func removeSelected<Element: Selectable>() where Value == [Element] {
        self = compactMapValues { $0.filter { !$0.selected }.isEmpty ? nil : $0.filter { !$0.selected } }
    }

    func isAllSelected<Element: Selectable>() -> Bool where Value == [Element] {
        values.allSatisfy(\.isAllSelected)
    }

    func selected<Element: Selectable>() -> some BidirectionalCollection<Element> where Value == [Element] {
        map(\.value.selected).joined()
    }
}
