//
//  Asset.swift
//  Taichi
//
//  Created by Toan Nguyen on 17/9/25.
//

import Foundation
import UIKit

extension Equatable {
    @inlinable
    func iPad(_ v: Self) -> Self { support(self, v) }
}

extension AdditiveArithmetic {
    @inlinable
    func iPad() -> Self { support(self, self + self) }
}

extension String {
    @inlinable
    func iPad() -> String { support(self, "\(self)iPad") }
}

@inlinable
public func support<Value>(_ iPhone: Value, _ iPad: Value) -> Value {
    UIDevice.current.userInterfaceIdiom == .pad ? iPad : iPhone
}

public func dismissKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
}

var isIPad: Bool {
    UIDevice.current.userInterfaceIdiom == .pad
}
