//
//  PuzzleFixtures.swift
//  iykyk
//
//  Created by Patrick McKowen on 11/18/25.
//

import Foundation

struct PuzzleFixtures {
    /// Creates an empty puzzle with full 4×4 structure (4 groups × 4 words with empty text)
    /// Ready for creation UI to render immediately
    static func sampleEmptyPuzzle() -> Puzzle {
        let sequenceNumber = PuzzleNumberingService.nextSequenceNumber()
        
        let groups = (0...3).map { groupPosition in
            let words = (0...3).map { wordPosition in
                PuzzleWord(text: "", position: wordPosition)
            }
            return PuzzleGroup(title: "", position: groupPosition, words: words)
        }
        
        return Puzzle(
            sequenceNumber: sequenceNumber,
            title: "New Puzzle",
            creatorName: nil,
            groups: groups
        )
    }
    
    /// Creates a partially filled puzzle with some content
    static func samplePartialPuzzle() -> Puzzle {
        // Group 0 - Fully filled
        let group0Words = [
            PuzzleWord(text: "LATTE", position: 0),
            PuzzleWord(text: "MOCHA", position: 1),
            PuzzleWord(text: "ESPRESSO", position: 2),
            PuzzleWord(text: "CAPPUCCINO", position: 3)
        ]
        let group0 = PuzzleGroup(title: "Coffee Drinks", position: 0, words: group0Words)
        
        // Group 1 - Partially filled
        let group1Words = [
            PuzzleWord(text: "PYTHON", position: 0),
            PuzzleWord(text: "SWIFT", position: 1),
            PuzzleWord(text: "", position: 2),
            PuzzleWord(text: "", position: 3)
        ]
        let group1 = PuzzleGroup(title: "Programming Languages", position: 1, words: group1Words)
        
        // Group 2 - Empty words, no title
        let group2Words = (0...3).map { PuzzleWord(text: "", position: $0) }
        let group2 = PuzzleGroup(title: "", position: 2, words: group2Words)
        
        // Group 3 - Empty words, no title
        let group3Words = (0...3).map { PuzzleWord(text: "", position: $0) }
        let group3 = PuzzleGroup(title: "", position: 3, words: group3Words)
        
        return Puzzle(
            title: "Partial Puzzle",
            creatorName: "Creator",
            groups: [group0, group1, group2, group3]
        )
    }
    
    /// Creates a fully valid and complete 4×4 puzzle
    static func sampleCompletedPuzzle() -> Puzzle {
        // Group 0 - Coffee Drinks
        let group0Words = [
            PuzzleWord(text: "LATTE", position: 0),
            PuzzleWord(text: "MOCHA", position: 1),
            PuzzleWord(text: "ESPRESSO", position: 2),
            PuzzleWord(text: "CAPPUCCINO", position: 3)
        ]
        let group0 = PuzzleGroup(title: "Coffee Drinks", position: 0, words: group0Words)
        
        // Group 1 - Programming Languages
        let group1Words = [
            PuzzleWord(text: "PYTHON", position: 0),
            PuzzleWord(text: "SWIFT", position: 1),
            PuzzleWord(text: "RUST", position: 2),
            PuzzleWord(text: "GO", position: 3)
        ]
        let group1 = PuzzleGroup(title: "Programming Languages", position: 1, words: group1Words)
        
        // Group 2 - Apple Products
        let group2Words = [
            PuzzleWord(text: "IPHONE", position: 0),
            PuzzleWord(text: "IPAD", position: 1),
            PuzzleWord(text: "MACBOOK", position: 2),
            PuzzleWord(text: "AIRPODS", position: 3)
        ]
        let group2 = PuzzleGroup(title: "Apple Products", position: 2, words: group2Words)
        
        // Group 3 - NYT Games
        let group3Words = [
            PuzzleWord(text: "WORDLE", position: 0),
            PuzzleWord(text: "STRANDS", position: 1),
            PuzzleWord(text: "CONNECTIONS", position: 2),
            PuzzleWord(text: "SPELLING BEE", position: 3)
        ]
        let group3 = PuzzleGroup(title: "NYT Games", position: 3, words: group3Words)
        
        return Puzzle(
            title: "Tech & Coffee",
            creatorName: "Creator",
            groups: [group0, group1, group2, group3]
        )
    }
    
    /// Creates a published puzzle with a specific play status
    /// - Parameters:
    ///   - playStatus: The play status for the puzzle (default: .notStarted)
    ///   - sequenceNumber: Optional sequence number for display
    ///   - solvedGroupPositions: Set of group positions that have been solved during gameplay
    /// - Returns: A fully valid, published puzzle
    static func samplePublishedPuzzle(
        playStatus: PuzzlePlayStatus = .notStarted,
        sequenceNumber: Int? = nil,
        solvedGroupPositions: Set<Int> = []
    ) -> Puzzle {
        // Group 0 - Colors
        let group0Words = [
            PuzzleWord(text: "CRIMSON", position: 0),
            PuzzleWord(text: "SCARLET", position: 1),
            PuzzleWord(text: "RUBY", position: 2),
            PuzzleWord(text: "VERMILLION", position: 3)
        ]
        let group0 = PuzzleGroup(title: "Shades of Red", position: 0, words: group0Words)
        
        // Group 1 - Trees
        let group1Words = [
            PuzzleWord(text: "OAK", position: 0),
            PuzzleWord(text: "MAPLE", position: 1),
            PuzzleWord(text: "BIRCH", position: 2),
            PuzzleWord(text: "WILLOW", position: 3)
        ]
        let group1 = PuzzleGroup(title: "Types of Trees", position: 1, words: group1Words)
        
        // Group 2 - Planets
        let group2Words = [
            PuzzleWord(text: "MARS", position: 0),
            PuzzleWord(text: "VENUS", position: 1),
            PuzzleWord(text: "SATURN", position: 2),
            PuzzleWord(text: "JUPITER", position: 3)
        ]
        let group2 = PuzzleGroup(title: "Planets", position: 2, words: group2Words)
        
        // Group 3 - Card Games
        let group3Words = [
            PuzzleWord(text: "POKER", position: 0),
            PuzzleWord(text: "BRIDGE", position: 1),
            PuzzleWord(text: "RUMMY", position: 2),
            PuzzleWord(text: "SOLITAIRE", position: 3)
        ]
        let group3 = PuzzleGroup(title: "Card Games", position: 3, words: group3Words)
        
        return Puzzle(
            sequenceNumber: sequenceNumber,
            title: "Nature & Games",
            creatorName: "Preview",
            publishedAt: Date(),
            playStatus: playStatus,
            solvedGroupPositions: solvedGroupPositions,
            groups: [group0, group1, group2, group3]
        )
    }
}

