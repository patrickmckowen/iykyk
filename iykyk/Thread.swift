//
//  Thread.swift
//  iykyk
//
//  Created by Patrick McKowen on 8/23/24.
//

import Foundation
import SwiftUI

enum Difficulty: Int, CaseIterable {
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

struct Thread: Identifiable {
    let id = UUID()
    var name: String
    var words: [Word]
    var difficulty: Difficulty

    var color: Color {
        difficulty.color
    }
}
