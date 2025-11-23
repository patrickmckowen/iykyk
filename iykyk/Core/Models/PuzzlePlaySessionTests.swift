//
//  PuzzlePlaySessionTests.swift
//  iykyk
//
//  Created by AI Assistant on 11/23/25.
//
//  Simple inline test harness for PuzzlePlaySession logic.
//  This is a minimal validation file and can be removed once proper unit tests are in place.

import Foundation

#if DEBUG
struct PuzzlePlaySessionTests {
    static func runTests() {
        print("🧪 Running PuzzlePlaySession tests...")
        
        testCorrectGuess()
        testIncorrectGuess()
        testWinCondition()
        testLoseCondition()
        testInvalidPuzzle()
        
        print("✅ All PuzzlePlaySession tests passed!")
    }
    
    private static func testCorrectGuess() {
        let puzzle = PuzzleFixtures.sampleCompletedPuzzle()
        var session = PuzzlePlaySession(puzzle: puzzle)
        
        // Find 4 tiles from the same group
        let firstGroupID = session.tiles.first!.groupID
        let tilesFromFirstGroup = session.tiles.filter { $0.groupID == firstGroupID }
        
        // Select all 4 tiles
        for tile in tilesFromFirstGroup {
            session.toggleSelection(for: tile.id)
        }
        
        assert(session.selectedTileIDs.count == 4, "Should have 4 tiles selected")
        assert(session.canSubmitGuess, "Should be able to submit")
        
        let result = session.submitGuess()
        
        if case .correct = result {
            assert(session.solvedGroupIDs.count == 1, "Should have 1 solved group")
            assert(session.selectedTileIDs.isEmpty, "Selection should be cleared")
            assert(session.guessesRemaining == 3, "Should still have 3 guesses")
        } else {
            fatalError("Expected correct result")
        }
        
        print("  ✓ testCorrectGuess passed")
    }
    
    private static func testIncorrectGuess() {
        let puzzle = PuzzleFixtures.sampleCompletedPuzzle()
        var session = PuzzlePlaySession(puzzle: puzzle)
        
        // Select tiles from different groups
        var selectedTiles: [WordTile] = []
        var seenGroupIDs = Set<UUID>()
        
        for tile in session.tiles {
            if !seenGroupIDs.contains(tile.groupID) && selectedTiles.count < 4 {
                selectedTiles.append(tile)
                seenGroupIDs.insert(tile.groupID)
            }
        }
        
        for tile in selectedTiles {
            session.toggleSelection(for: tile.id)
        }
        
        let result = session.submitGuess()
        
        if case .incorrect = result {
            assert(session.solvedGroupIDs.isEmpty, "Should have 0 solved groups")
            assert(session.selectedTileIDs.isEmpty, "Selection should be cleared")
            assert(session.guessesRemaining == 2, "Should have 2 guesses left")
        } else {
            fatalError("Expected incorrect result")
        }
        
        print("  ✓ testIncorrectGuess passed")
    }
    
    private static func testWinCondition() {
        let puzzle = PuzzleFixtures.sampleCompletedPuzzle()
        var session = PuzzlePlaySession(puzzle: puzzle)
        
        // Solve all 4 groups
        let groupIDs = Set(session.tiles.map { $0.groupID })
        
        for groupID in groupIDs {
            let tilesInGroup = session.tiles.filter { $0.groupID == groupID }
            for tile in tilesInGroup {
                session.toggleSelection(for: tile.id)
            }
            session.submitGuess()
        }
        
        assert(session.state == .won, "Should be in won state")
        assert(session.solvedGroupIDs.count == 4, "Should have 4 solved groups")
        
        print("  ✓ testWinCondition passed")
    }
    
    private static func testLoseCondition() {
        let puzzle = PuzzleFixtures.sampleCompletedPuzzle()
        var session = PuzzlePlaySession(puzzle: puzzle)
        
        // Make 3 incorrect guesses
        for _ in 0..<3 {
            // Select tiles from different groups
            var selectedTiles: [WordTile] = []
            var seenGroupIDs = Set<UUID>()
            
            for tile in session.tiles {
                if !seenGroupIDs.contains(tile.groupID) && 
                   !session.solvedGroupIDs.contains(tile.groupID) &&
                   selectedTiles.count < 4 {
                    selectedTiles.append(tile)
                    seenGroupIDs.insert(tile.groupID)
                }
            }
            
            for tile in selectedTiles {
                session.toggleSelection(for: tile.id)
            }
            
            session.submitGuess()
        }
        
        assert(session.state == .lost, "Should be in lost state")
        assert(session.guessesRemaining == 0, "Should have 0 guesses left")
        assert(!session.canSubmitGuess, "Should not be able to submit more guesses")
        
        print("  ✓ testLoseCondition passed")
    }
    
    private static func testInvalidPuzzle() {
        // Create a puzzle with only 2 groups (invalid)
        let group1 = PuzzleGroup(title: "Group 1", position: 0, words: [
            PuzzleWord(text: "A", position: 0),
            PuzzleWord(text: "B", position: 1),
            PuzzleWord(text: "C", position: 2),
            PuzzleWord(text: "D", position: 3)
        ])
        
        let group2 = PuzzleGroup(title: "Group 2", position: 1, words: [
            PuzzleWord(text: "E", position: 0),
            PuzzleWord(text: "F", position: 1),
            PuzzleWord(text: "G", position: 2),
            PuzzleWord(text: "H", position: 3)
        ])
        
        let invalidPuzzle = Puzzle(title: "Invalid", groups: [group1, group2])
        
        // Session can still be created; validation is handled externally.
        _ = PuzzlePlaySession(puzzle: invalidPuzzle)
        
        print("  ✓ testInvalidPuzzle passed (creation allowed; external validation required)")
    }
}
#endif

