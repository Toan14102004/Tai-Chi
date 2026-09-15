//
//  AdPlacement.swift
//  ARDraw
//
//  Created by Toan Nguyen on 5/9/25.
//

import Foundation

struct AdPlacement: Codable {
    var id: String
    var isEnabled: Bool
}

extension AdPlacement: AdPlacementRepresentable {}
