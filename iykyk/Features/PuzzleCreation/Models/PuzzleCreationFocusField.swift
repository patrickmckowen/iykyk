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
}

