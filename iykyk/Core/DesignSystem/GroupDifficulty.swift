//
//  GroupDifficulty.swift
//  iykyk
//
//  Created by Patrick McKowen on 11/22/25.
//

import SwiftUI

/// Semantic difficulty levels for the four puzzle groups
enum GroupDifficulty {
    /// Returns the difficulty label for a given group position (0-3)
    static func label(for position: Int) -> String {
        switch position {
        case 0:
            return "Fiendish"
        case 1:
            return "Tricky"
        case 2:
            return "Fun"
        case 3:
            return "Simple"
        default:
            return ""
        }
    }
    
    /// Returns the difficulty color for a given group position (0-3)
    /// This maps to the same colors as GroupColors for consistency
    static func color(for position: Int) -> Color {
        GroupColors.color(for: position)
    }
}

