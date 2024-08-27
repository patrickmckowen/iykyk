//
//  Thread.swift
//  iykyk
//
//  Created by Patrick McKowen on 8/23/24.
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class Thread {
    var id: UUID
    var name: String
    var words: [Word]
    var difficulty: Difficulty

    var color: Color {
        difficulty.color
    }

    init(id: UUID = UUID(), name: String, words: [Word], difficulty: Difficulty) {
        self.id = id
        self.name = name
        self.words = words
        self.difficulty = difficulty
    }
}

enum Difficulty: Int, CaseIterable, Codable {
    case easy = 1
    case medium = 2
    case hard = 3
    case expert = 4

    var color: Color {
        switch self {
        case .easy: return .yellow
        case .medium: return .green
        case .hard: return .blue
        case .expert: return .purple
        }
    }
}
