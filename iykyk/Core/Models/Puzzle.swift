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
    
    /// Stores solved group positions as array (SwiftData doesn't support Set directly)
    var solvedGroupPositionsRaw: [Int] = []
    
    /// Number of incorrect guesses remaining (starts at 4)
    var guessesRemaining: Int = 4
    
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
    
    /// Tracks which group positions (0-3) have been solved during gameplay
    var solvedGroupPositions: Set<Int> {
        get {
            Set(solvedGroupPositionsRaw)
        }
        set {
            solvedGroupPositionsRaw = Array(newValue).sorted()
        }
    }
    
    /// Returns the UUIDs of solved groups, sorted by position
    var solvedGroupIDs: [UUID] {
        groups
            .filter { solvedGroupPositions.contains($0.position) }
            .sorted { $0.position < $1.position }
            .map { $0.id }
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
    
    /// Returns all non-empty words as a title-cased preview string, or "Empty Puzzle" if none.
    /// The UI will truncate naturally based on available space.
    var wordPreview: String {
        let allWords = groups
            .sorted { $0.position < $1.position }
            .flatMap { $0.words.sorted { $0.position < $1.position } }
            .map { $0.text.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .map { $0.capitalized }
        
        if allWords.isEmpty {
            return "Empty Puzzle"
        }
        
        return allWords.joined(separator: ", ")
    }
    
    /// Count of non-empty words in the puzzle (0-16).
    var filledWordCount: Int {
        groups
            .flatMap { $0.words }
            .filter { !$0.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .count
    }
    
    /// Returns a set of group positions (0-3) where all 4 words are filled.
    var completedGroupPositions: Set<Int> {
        var completed = Set<Int>()
        for group in groups {
            let filledCount = group.words.filter {
                !$0.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            }.count
            if filledCount == 4 {
                completed.insert(group.position)
            }
        }
        return completed
    }
    
    init(
        id: UUID = UUID(),
        sequenceNumber: Int? = nil,
        title: String = "New Puzzle",
        creatorName: String? = nil,
        createdAt: Date = Date(),
        publishedAt: Date? = nil,
        playStatus: PuzzlePlayStatus = .notStarted,
        solvedGroupPositions: Set<Int> = [],
        guessesRemaining: Int = 4,
        groups: [PuzzleGroup] = []
    ) {
        self.id = id
        self.sequenceNumber = sequenceNumber
        self.title = title
        self.creatorName = creatorName
        self.createdAt = createdAt
        self.publishedAt = publishedAt
        self.playStatusRaw = playStatus.rawValue
        self.solvedGroupPositionsRaw = Array(solvedGroupPositions).sorted()
        self.guessesRemaining = guessesRemaining
        self.groups = groups
    }
}

