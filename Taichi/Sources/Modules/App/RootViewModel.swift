//
//  RootViewModel.swift
//  Taichi
//
//  Created by Toan Nguyen on 20/11/24.
//

import Combine
import Foundation
import SwiftUI

extension RootView {
    class ViewModel: ObservableObject {
        
        @Injected var adsManager: AdsManager
        @Injected var localStorageService: LocalStorageService
        
        @Published var path = FlowPath()
        @Published var coordinator = Coordinator()

        private let cancelBag = CancelBag()

        init(container: DIContainer) {
            container.appState.updates(for: \.path)
                .sink { [weak self] newPath in
                    guard let self else { return }
                    if path != newPath {
                        path = newPath
                    }
                }
                .store(in: cancelBag)
        }
    }
}
