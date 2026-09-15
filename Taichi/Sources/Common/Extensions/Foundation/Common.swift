//
//  Common.swift
//  Taichi
//
//  Created by Toan Nguyen on 16/3/25.
//

import Foundation

extension String {
    var symbol: Character {
        guard let c = first, c.isLetter else {
            return Character("#")
        }
        return c.convertToUpperCase()
    }

    var withWhitespace: String {
        isEmpty ? "" : "\(self) "
    }

    func convertToValidFileName() -> String {
        components(separatedBy: .init(charactersIn: "/:?%*|\"<>")).joined(separator: "_")
    }
}

extension Character {
    func convertToUpperCase() -> Character {
        if isUppercase {
            return self
        }
        return Character(uppercased())
    }
}
