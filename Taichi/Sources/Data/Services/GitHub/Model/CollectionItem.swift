//
//  CollectionItem.swift
//  Taichi
//
//  Model for decoding collection.json from GitHub.
//

import Foundation

// MARK: - Response wrapper
struct CollectionItemResponse: Codable {
    let items: [CollectionItem]
}

// MARK: - Single collection item
struct CollectionItem: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let image: String
    let series: String
    
    /// Convert the string id from JSON to a deterministic UUID.
    var uuid: UUID {
        UUID(uuidString: id) ?? UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
    }
}
