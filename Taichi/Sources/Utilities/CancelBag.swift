//
//  CancelBag.swift
//  Taichi
//
//  Created by Toan Nguyen on 19/11/24.
//

import Combine
import Foundation

final class CancelBag {
    fileprivate(set) var subscriptions = Set<AnyCancellable>()
    private let equalToAny: Bool

    init(equalToAny: Bool = false) {
        self.equalToAny = equalToAny
    }

    func isEqual(to other: CancelBag) -> Bool {
        other === self || other.equalToAny || equalToAny
    }

    func cancel() {
        subscriptions.removeAll()
    }

    func collect(@Builder _ cancellables: () -> [AnyCancellable]) {
        subscriptions.formUnion(cancellables())
    }

    @resultBuilder
    struct Builder {
        static func buildBlock(_ cancellables: AnyCancellable...) -> [AnyCancellable] {
            cancellables
        }
    }
}

extension AnyCancellable {
    func store(in cancelBag: CancelBag) {
        cancelBag.subscriptions.insert(self)
    }
}
