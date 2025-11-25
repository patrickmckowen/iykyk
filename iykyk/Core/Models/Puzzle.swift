//
//  Puzzle.swift
//  iykyk
//
//  Created by Patrick McKowen on 11/18/25.
//

import Foundation
import SwiftData

enum PuzzlePlayStatus: String, Codable {
    case notStarted
    case inProgress
    case won
    case lost
    
    var displayText: String {
        switch self {
        case .notStarted: return "Not started"
        case .inProgress: return "In progress"
        case .won: return "Won"
        case .lost: return "Lost"
        }
    }
}

@Model
final class Puzzle {
    var id: UUID
    var sequenceNumber: Int?
    var title: String
    var creatorName: String?
    var createdAt: Date
    var publishedAt: Date?
    
    // SwiftData requires raw values for enums with default values
    // Must be internal (not private) for SwiftData to access it
    var playStatusRaw: String = PuzzlePlayStatus.notStarted.rawValue
    
    @Relationship(deleteRule: .cascade, inverse: \PuzzleGroup.puzzle)
    var groups: [PuzzleGroup]
    
    // Computed property for type-safe play status
    var playStatus: PuzzlePlayStatus {
        get {
            PuzzlePlayStatus(rawValue: playStatusRaw) ?? .notStarted
        }
        set {
            playStatusRaw = newValue.rawValue
        }
    }
    
    // Convenience computed properties
    var isPublished: Bool {
        publishedAt != nil
    }
    
    var publishStatusText: String {
        isPublished ? "Published" : "Draft"
    }
    
    var isPlayable: Bool {
        isPublished && (playStatus == .notStarted || playStatus == .inProgress)
    }
    
    /// Returns the display title for the puzzle.
    /// Uses custom title if set, otherwise generates "Puzzle #X" from sequence number.
    var displayTitle: String {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Use custom title if it's not empty and not the default
        if !trimmedTitle.isEmpty && trimmedTitle != "New Puzzle" {
            return trimmedTitle
        }
        
        // Fall back to "Puzzle #X" format
        if let number = sequenceNumber {
            return "Puzzle #\(number)"
        }
        
        // Draft puzzles without a custom title
        return "New Puzzle"
    }
    
    init(
        id: UUID = UUID(),
        sequenceNumber: Int? = nil,
        title: String = "New Puzzle",
        creatorName: String? = nil,
        createdAt: Date = Date(),
        publishedAt: Date? = nil,
        playStatus: PuzzlePlayStatus = .notStarted,
        groups: [PuzzleGroup] = []
    ) {
        self.id = id
        self.sequenceNumber = sequenceNumber
        self.title = title
        self.creatorName = creatorName
        self.createdAt = createdAt
        self.publishedAt = publishedAt
        self.playStatusRaw = playStatus.rawValue
        self.groups = groups
    }
}

