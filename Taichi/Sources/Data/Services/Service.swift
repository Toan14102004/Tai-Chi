//
//  Service.swift
//  Taichi
//
//  Created by Toan Nguyen on 18/11/24.
//

import Foundation

protocol Service {
    var shouldAutostart: Bool { get }

    func start()
    func stop()
}
