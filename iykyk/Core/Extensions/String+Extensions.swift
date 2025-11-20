//
//  String+Extensions.swift
//  iykyk
//
//  Created by Patrick McKowen on 11/20/25.
//

import Foundation

extension String {
    var containsOnlyEmoji: Bool {
        guard !isEmpty else { return false }
        return allSatisfy { $0.isEmoji }
    }
}

extension Character {
    var isEmoji: Bool {
        unicodeScalars.contains { scalar in
            scalar.properties.isEmoji &&
            (scalar.properties.isEmojiPresentation || !scalar.isASCII)
        }
    }
}
