//
//  PuzzleCreationFocusField.swift
//  iykyk
//
//  Focus field enum for puzzle creation keyboard navigation.
//

import Foundation

enum PuzzleCreationFocusField: Hashable {
    case groupName(groupIndex: Int)
    case word(groupIndex: Int, wordIndex: Int)
    
    /// Returns the group index for either focus field type
    var groupIndex: Int {
        switch self {
        case .groupName(let index): return index
        case .word(let groupIndex, _): return groupIndex
        }
    }
}

