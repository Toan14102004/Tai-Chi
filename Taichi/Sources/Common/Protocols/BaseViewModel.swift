//
//  BaseViewModel.swift
//  Taichi
//
//  Created by Toan Nguyen on 20/11/24.
//

import Foundation
import SwiftUI

protocol BaseViewModel: ObservableObject {
    associatedtype CoordinatorType: BaseCoordinator

    var coordinator: CoordinatorType { get }
}
