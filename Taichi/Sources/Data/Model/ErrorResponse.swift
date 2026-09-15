//
//  ErrorResponse.swift
//  Taichi
//
//  Created by Toan Nguyen on 2/2/26.
//

import Foundation

struct ErrorResponse: Decodable {
    let status: String
    let message: String
    let details: String?
}
