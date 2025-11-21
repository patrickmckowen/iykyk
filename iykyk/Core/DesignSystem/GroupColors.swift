//
//  GroupColors.swift
//  iykyk
//
//  Created by Patrick McKowen on 11/21/25.
//

import SwiftUI

/// Semantic colors for the four puzzle groups
enum GroupColors {
    /// Returns the semantic color for a given group position (0-3)
    static func color(for position: Int) -> Color {
        switch position {
        case 0:
            return .purple
        case 1:
            return .blue
        case 2:
            return .green
        case 3:
            return .yellow
        default:
            return .gray
        }
    }
}

