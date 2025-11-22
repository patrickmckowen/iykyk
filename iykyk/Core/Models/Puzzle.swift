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
    var sequenceNumber: Int?
    var title: String
    var creatorName: String?
    var createdAt: Date
    
    @Relationship(deleteRule: .cascade, inverse: \PuzzleGroup.puzzle)
    var groups: [PuzzleGroup]
    
    init(
        id: UUID = UUID(),
        sequenceNumber: Int? = nil,
        title: String = "New Puzzle",
        creatorName: String? = nil,
        createdAt: Date = Date(),
        groups: [PuzzleGroup] = []
    ) {
        self.id = id
        self.sequenceNumber = sequenceNumber
        self.title = title
        self.creatorName = creatorName
        self.createdAt = createdAt
        self.groups = groups
    }
}

