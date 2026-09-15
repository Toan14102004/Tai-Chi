//
//  OnDemandResourceTag.swift
//  Taichi
//
//  Created by Assistant on 10/16/25.
//

import Foundation

enum OnDemandResourceTag: Hashable {
    case location
    case custom(String)
    case group(Set<OnDemandResourceTag>)

    var strings: Set<String> {
        switch self {
        case .location:
            return ["location"]
        case let .custom(tag):
            return [tag]
        case let .group(tags):
            return tags.reduce(into: Set<String>()) { result, tag in
                result.formUnion(tag.strings)
            }
        }
    }

    var normalizedKey: Set<String> { strings }
}


