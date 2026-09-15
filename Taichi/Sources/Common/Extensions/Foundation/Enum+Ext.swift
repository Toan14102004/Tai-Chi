//
//  Enum+Ext.swift
//  Taichi
//
//  Created by Toan Nguyen on 20/5/25.
//

import Foundation

protocol Nextable: CaseIterable where AllCases: RandomAccessCollection, AllCases.Index == Int {
    mutating func next(_ action: (() -> Void)?)
}

extension Nextable where Self: Equatable {
    mutating func next(_ onFinal: (() -> Void)? = nil) {
        let allCases = Array(Self.allCases)
        if let currentIndex = allCases.firstIndex(of: self) {
            let nextIndex = allCases.index(after: currentIndex)
            if allCases.indices.contains(nextIndex) {
                self = allCases[nextIndex]
            } else {
                onFinal?()
                self = allCases.first!
            }
        }
    }
}
