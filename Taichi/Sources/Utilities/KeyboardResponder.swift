//
//  KeyboardResponder.swift
//  Taichi
//
//  Created by Toan Nguyen on 20/5/25.
//

import Combine
import Foundation
import SwiftUI

class KeyboardResponder: ObservableObject {
    @Published var keyboardHeight: CGFloat = 0

    private var cancellableSet: Set<AnyCancellable> = []

    init() {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .merge(with: NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification))
            .receive(on: DispatchQueue.main)
            .sink { notification in
                if let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    self.keyboardHeight = frame.height
                }
            }
            .store(in: &cancellableSet)

        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.keyboardHeight = 0
            }
            .store(in: &cancellableSet)
    }
}
