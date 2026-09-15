//
//  GitHubModels.swift
//  CameraLocation
//
//  Created by Guest User on 23/1/26.
//

import Foundation

// GitHub API response for file content
struct GitHubFileContent: Codable {
    let content: String
    let encoding: String
}

