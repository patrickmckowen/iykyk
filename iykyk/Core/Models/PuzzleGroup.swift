//
//  PuzzleGroup.swift
//  iykyk
//
//  Created by Patrick McKowen on 11/18/25.
//

import Foundation
import SwiftData

@Model
final class PuzzleGroup {
    var id: UUID
    var title: String
    var position: Int
    
    @Relationship(deleteRule: .cascade, inverse: \PuzzleWord.group)
    var words: [PuzzleWord]
    
    var puzzle: Puzzle?
    
    init(id: UUID = UUID(), title: String = "", position: Int, words: [PuzzleWord] = []) {
        self.id = id
        self.title = title
        self.position = position
        self.words = words
    }
}

