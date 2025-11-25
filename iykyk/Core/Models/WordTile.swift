//
//  WordTile.swift
//  iykyk
//
//  Created by AI Assistant on 11/23/25.
//

import Foundation

/// A UI-focused representation of a word tile used during gameplay.
/// Not persisted; created by flattening a Puzzle's groups and words.
struct WordTile: Identifiable, Equatable {
    let id: UUID
    let text: String
    let groupID: UUID
    
    init(id: UUID, text: String, groupID: UUID) {
        self.id = id
        self.text = text
        self.groupID = groupID
    }
}



