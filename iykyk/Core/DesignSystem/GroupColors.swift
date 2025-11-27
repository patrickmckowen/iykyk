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
            return Color(red: 0.655, green: 0.545, blue: 0.980) // Violet-400
        case 1:
            return Color(red: 0.373, green: 0.667, blue: 0.949) // Blue-400
        case 2:
            return Color(red: 0.298, green: 0.851, blue: 0.392) // Green-400
        case 3:
            return Color(red: 0.988, green: 0.827, blue: 0.302) // Amber-300
        default:
            return .gray
        }
    }
}
