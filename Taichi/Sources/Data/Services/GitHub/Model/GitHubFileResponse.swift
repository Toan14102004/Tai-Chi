//
//  GitHubFileResponse.swift
//  CameraLocation
//
//  Created by Guest User on 23/1/26.
//

import Foundation

struct GitHubFileResponse: Codable {
    let name: String
    let path: String
    let sha: String
    let size: Int
    let url: String
    let htmlUrl: String
    let gitUrl: String
    let downloadUrl: String
    let type: String
    let content: String
    let encoding: String
    
    enum CodingKeys: String, CodingKey {
        case name, path, sha, size, url
        case htmlUrl = "html_url"
        case gitUrl = "git_url"
        case downloadUrl = "download_url"
        case type, content, encoding
    }
}
