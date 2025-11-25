//
//  PreviewSampleData.swift
//  iykyk
//
//  Helper for creating pre-seeded model containers for SwiftUI previews.
//

import Foundation
import SwiftData

struct PreviewSampleData {
    /// Creates an in-memory ModelContainer pre-seeded with sample puzzles
    /// for testing library views in both Create and Play modes.
    @MainActor
    static func seededContainer() throws -> ModelContainer {
        let schema = Schema([Puzzle.self, PuzzleGroup.self, PuzzleWord.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [config])
        
        // Draft puzzles (for Create mode)
        let emptyDraft = PuzzleFixtures.sampleEmptyPuzzle()
        emptyDraft.sequenceNumber = 1
        container.mainContext.insert(emptyDraft)
        
        let partialDraft = PuzzleFixtures.samplePartialPuzzle()
        partialDraft.sequenceNumber = 2
        container.mainContext.insert(partialDraft)
        
        // Published puzzles (for both Create and Play modes)
        let publishedNotStarted = PuzzleFixtures.samplePublishedPuzzle(
            playStatus: .notStarted,
            sequenceNumber: 3
        )
        container.mainContext.insert(publishedNotStarted)
        
        let publishedInProgress = PuzzleFixtures.samplePublishedPuzzle(
            playStatus: .inProgress,
            sequenceNumber: 4
        )
        container.mainContext.insert(publishedInProgress)
        
        let publishedWon = PuzzleFixtures.samplePublishedPuzzle(
            playStatus: .won,
            sequenceNumber: 5
        )
        container.mainContext.insert(publishedWon)
        
        return container
    }
}

