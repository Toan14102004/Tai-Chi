//
//  FocusableField.swift
//  Taichi
//
//  Created by Toan Nguyen on 10/13/25.
//

import Foundation

// MARK: - FocusableField Protocol

protocol FocusableField: CaseIterable, Equatable, Hashable {
    var previous: Self? { get }
    var next: Self? { get }
}

extension FocusableField {
    var previous: Self? {
        let allCases = Array(Self.allCases)
        guard let currentIndex = allCases.firstIndex(of: self) else { return nil }
        return currentIndex > 0 ? allCases[currentIndex - 1] : nil
    }

    var next: Self? {
        let allCases = Array(Self.allCases)
        guard let currentIndex = allCases.firstIndex(of: self) else { return nil }
        return currentIndex < allCases.count - 1 ? allCases[currentIndex + 1] : nil
    }
}
