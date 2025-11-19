//
//  Puzzle.swift
//  iykyk
//
//  Created by Patrick McKowen on 11/18/25.
//

import Foundation
import SwiftData

@Model
final class Puzzle {
    var id: UUID
    var title: String
    var creatorName: String?
    var createdAt: Date
    
    @Relationship(deleteRule: .cascade, inverse: \PuzzleGroup.puzzle)
    var groups: [PuzzleGroup]
    
    init(
        id: UUID = UUID(),
        title: String = "New Puzzle",
        creatorName: String? = nil,
        createdAt: Date = Date(),
        groups: [PuzzleGroup] = []
    ) {
        self.id = id
        self.title = title
        self.creatorName = creatorName
        self.createdAt = createdAt
        self.groups = groups
    }
}

