//
//  PuzzlePlaySession.swift
//  iykyk
//
//  Created by AI Assistant on 11/23/25.
//

import Foundation

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
struct PuzzlePlaySession {
    // Core session state
    private(set) var tiles: [WordTile] = []
    private(set) var selectedTileIDs: Set<UUID> = []
    private(set) var solvedGroupIDs: Set<UUID> = []
    private(set) var guessesRemaining: Int = 3
    private(set) var state: PuzzlePlayState = .inProgress
    private(set) var lastGuessResult: GuessResult?
    
    private var groupsByID: [UUID: PuzzleGroup] = [:]
    
    /// Creates a new play session derived from a given `Puzzle`.
    init(puzzle: Puzzle) {
        var lookup: [UUID: PuzzleGroup] = [:]
        for group in puzzle.groups {
            lookup[group.id] = group
        }
        self.groupsByID = lookup
        
        let allTiles: [WordTile] = puzzle.groups.flatMap { group in
            group.words.map { word in
                WordTile(id: word.id, text: word.text, groupID: group.id)
            }
        }
        self.tiles = allTiles.shuffled()
    }
    
    /// Returns tiles that should be displayed (not yet solved).
    var activeTiles: [WordTile] {
        tiles.filter { !solvedGroupIDs.contains($0.groupID) }
    }
    
    /// Returns tiles that are part of solved groups, in solution order.
    var solvedTiles: [WordTile] {
        let solved = tiles.filter { solvedGroupIDs.contains($0.groupID) }
        // Sort by group position
        return solved.sorted { tile1, tile2 in
            guard let group1 = groupsByID[tile1.groupID],
                  let group2 = groupsByID[tile2.groupID] else {
                return false
            }
            return group1.position < group2.position
        }
    }
    
    /// Can the user currently submit a guess?
    var canSubmitGuess: Bool {
        selectedTileIDs.count == 4 && state == .inProgress
    }
    
    /// Toggles selection of a tile. Only works if tile is active and game is in progress.
    mutating func toggleSelection(for tileID: UUID) {
        guard state == .inProgress else { return }
        
        // Check if tile is part of a solved group
        if let tile = tiles.first(where: { $0.id == tileID }),
           solvedGroupIDs.contains(tile.groupID) {
            return
        }
        
        if selectedTileIDs.contains(tileID) {
            selectedTileIDs.remove(tileID)
        } else {
            // Only allow selecting up to 4 tiles
            guard selectedTileIDs.count < 4 else { return }
            selectedTileIDs.insert(tileID)
        }
        
        // Clear last guess result when user changes selection
        lastGuessResult = nil
    }
    
    /// Submits the current selection as a guess.
    /// Returns the result of the guess.
    @discardableResult
    mutating func submitGuess() -> GuessResult? {
        guard canSubmitGuess else { return nil }
        
        // Get the group IDs of all selected tiles
        let selectedTiles = tiles.filter { selectedTileIDs.contains($0.id) }
        let selectedGroupIDs = Set(selectedTiles.map { $0.groupID })
        
        // Check if all 4 tiles belong to the same group
        if selectedGroupIDs.count == 1,
           let groupID = selectedGroupIDs.first,
           !solvedGroupIDs.contains(groupID) {
            // Correct guess!
            solvedGroupIDs.insert(groupID)
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
            guessesRemaining -= 1
            selectedTileIDs.removeAll()
            
            // Check for lose condition
            if guessesRemaining == 0 {
                state = .lost
            }
            
            let result = GuessResult.incorrect
            lastGuessResult = result
            return result
        }
    }
    
    /// Deselects all tiles.
    mutating func clearSelection() {
        selectedTileIDs.removeAll()
    }
}

