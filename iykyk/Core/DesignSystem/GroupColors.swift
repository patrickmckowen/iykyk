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
            return Color(red: 0.70, green: 0.65, blue: 0.85)
        case 1:
            return Color(red: 0.55, green: 0.75, blue: 0.90)
        case 2:
            return Color(red: 0.65, green: 0.82, blue: 0.68)
        case 3:
            return Color(red: 0.95, green: 0.85, blue: 0.60)
        default:
            return .gray
        }
    }
}
