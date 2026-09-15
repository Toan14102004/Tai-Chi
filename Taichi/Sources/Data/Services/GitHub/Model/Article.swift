//
//  Article.swift
//  Taichi
//
//  Created by Agent on 2/2/26.
//

import Foundation

// MARK: - Article Item
struct ArticleItem: Codable, Hashable, Identifiable {
  let thumb: String
  let headline: String
  let subHeadline: String
  let sections: [ArticleSection]

  var id: String { headline }

  enum CodingKeys: String, CodingKey {
    case thumb
    case headline
    case subHeadline = "sub_headline"
    case sections
  }
}

// MARK: - Article Section
struct ArticleSection: Codable, Hashable, Identifiable {
  let title: String
  let image: String
  let extra: String
  let content: String

  var id: String { UUID().uuidString }

    init(title: String, image: String, extra: String, content: String) {
        self.title = title
        self.image = image
        self.extra = extra
        self.content = content
    }
    
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
    image = try container.decodeIfPresent(String.self, forKey: .image) ?? ""
    extra = try container.decodeIfPresent(String.self, forKey: .extra) ?? ""
    content = try container.decodeIfPresent(String.self, forKey: .content) ?? ""
  }

  enum CodingKeys: String, CodingKey {
    case title, image, extra, content
  }
}
