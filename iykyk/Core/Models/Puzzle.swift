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
    
    // SwiftData requires raw values for enums, not the enum directly
    private var playStatusRaw: String
    
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

