//
//  PuzzlePlaySession.swift
//  iykyk
//
//  Created by AI Assistant on 11/23/25.
//

import Foundation
import Observation

/// Represents the current state of an active puzzle play session.
enum PuzzlePlayState {
    case inProgress
    case won
    case lost
}

/// Result of submitting a guess.
enum GuessResult {
    case correct(groupID: UUID, groupTitle: String)
    case incorrect
}

/// Manages the state and logic for playing a puzzle.
@Observable
class PuzzlePlaySession {
    // Core session state
    var tiles: [WordTile] = []
    var selectedTileIDs: [UUID] = []
    var solvedGroupIDs: [UUID] = []
    var guessesRemaining: Int = 4
    var state: PuzzlePlayState = .inProgress
    var lastGuessResult: GuessResult?
    
    private var groupsByID: [UUID: PuzzleGroup] = [:]
    
    /// Creates a new play session derived from a given `Puzzle`.
    /// Restores any previously solved groups and guesses remaining from the puzzle state.
    init(puzzle: Puzzle) {
        var lookup: [UUID: PuzzleGroup] = [:]
        for group in puzzle.groups {
            lookup[group.id] = group
        }
        self.groupsByID = lookup
        
        // Restore solved groups from puzzle (sorted by position)
        self.solvedGroupIDs = puzzle.solvedGroupIDs
        
        // Restore guesses remaining
        self.guessesRemaining = puzzle.guessesRemaining
        
        let allTiles: [WordTile] = puzzle.groups.flatMap { group in
            group.words.map { word in
                WordTile(id: word.id, text: word.text, groupID: group.id)
            }
        }
        self.tiles = allTiles.shuffled()
    }
    
    /// Returns all 16 tiles in display order: solved groups at top (in solve order), then unsolved tiles.
    var orderedTiles: [WordTile] {
        // Solved tiles sorted by solve order (index in solvedGroupIDs array)
        let solved = tiles.filter { solvedGroupIDs.contains($0.groupID) }
            .sorted { tile1, tile2 in
                guard let index1 = solvedGroupIDs.firstIndex(of: tile1.groupID),
                      let index2 = solvedGroupIDs.firstIndex(of: tile2.groupID) else {
                    return false
                }
                if index1 != index2 {
                    return index1 < index2
                }
                // Within same group, maintain original order
                guard let pos1 = tiles.firstIndex(where: { $0.id == tile1.id }),
                      let pos2 = tiles.firstIndex(where: { $0.id == tile2.id }) else {
                    return false
                }
                return pos1 < pos2
            }
        
        // Unsolved tiles maintain their current shuffled order
        let unsolved = tiles.filter { !solvedGroupIDs.contains($0.groupID) }
        
        return solved + unsolved
    }
    
    /// Returns the group's difficulty position (0-3) if the tile is solved, nil otherwise.
    func groupDifficultyPosition(for tileID: UUID) -> Int? {
        guard let tile = tiles.first(where: { $0.id == tileID }),
              solvedGroupIDs.contains(tile.groupID),
              let group = groupsByID[tile.groupID] else {
            return nil
        }
        return group.position
    }
    
    /// Returns whether a tile belongs to a solved group.
    func isTileSolved(_ tileID: UUID) -> Bool {
        guard let tile = tiles.first(where: { $0.id == tileID }) else {
            return false
        }
        return solvedGroupIDs.contains(tile.groupID)
    }
    
    /// Can the user currently submit a guess?
    var canSubmitGuess: Bool {
        selectedTileIDs.count == 4 && state == .inProgress
    }
    
    /// Toggles selection of a tile. Only works if tile is active and game is in progress.
    func toggleSelection(for tileID: UUID) {
        guard state == .inProgress else { return }
        
        // Check if tile is part of a solved group
        if let tile = tiles.first(where: { $0.id == tileID }),
           solvedGroupIDs.contains(tile.groupID) {
            return
        }
        
        if selectedTileIDs.contains(tileID) {
            selectedTileIDs.removeAll(where: { $0 == tileID })
        } else {
            // Only allow selecting up to 4 tiles
            guard selectedTileIDs.count < 4 else { return }
            selectedTileIDs.append(tileID)
        }
        
        // Clear last guess result when user changes selection
        lastGuessResult = nil
    }
    
    /// Submits the current selection as a guess.
    /// Returns the result of the guess.
    @discardableResult
    func submitGuess() -> GuessResult? {
        guard canSubmitGuess else { return nil }
        
        // Get the group IDs of all selected tiles
        let selectedTiles = tiles.filter { selectedTileIDs.contains($0.id) }
        let selectedGroupIDs = Set(selectedTiles.map { $0.groupID })
        
        // Check if all 4 tiles belong to the same group
        if selectedGroupIDs.count == 1,
           let groupID = selectedGroupIDs.first,
           !solvedGroupIDs.contains(groupID) {
            // Correct guess!
            solvedGroupIDs.append(groupID)
            selectedTileIDs.removeAll()
            
            // Check for win condition
            if solvedGroupIDs.count == 4 {
                state = .won
            }
            
            let groupTitle = groupsByID[groupID]?.title ?? ""
            let result = GuessResult.correct(groupID: groupID, groupTitle: groupTitle)
            lastGuessResult = result
            return result
        } else {
            // Incorrect guess
            let result = GuessResult.incorrect
            lastGuessResult = result
            return result
        }
    }
    
    /// Applies the penalty for an incorrect guess.
    /// Should be called after the shake animation completes.
    func applyIncorrectGuessPenalty() {
        guessesRemaining -= 1
        selectedTileIDs.removeAll()
        
        // Check for lose condition
        if guessesRemaining == 0 {
            state = .lost
        }
    }
    
    /// Deselects all tiles.
    func clearSelection() {
        selectedTileIDs.removeAll()
    }
    
    /// Shuffles only the unsolved tiles, preserving solved tiles at their positions.
    func shuffle() {
        // Separate solved and unsolved tiles
        let solvedTiles = tiles.filter { solvedGroupIDs.contains($0.groupID) }
        var unsolvedTiles = tiles.filter { !solvedGroupIDs.contains($0.groupID) }
        
        // Shuffle only unsolved tiles
        unsolvedTiles.shuffle()
        
        // Recombine: solved tiles keep their relative positions, unsolved go after
        tiles = solvedTiles + unsolvedTiles
    }
}

