//
//  InMemoryPuzzleRepository.swift
//  iykyk
//
//  Created by Patrick McKowen on 11/18/25.
//

import Foundation

@Observable
final class InMemoryPuzzleRepository: PuzzleRepository {
    private var puzzles: [Puzzle] = []
    
    init(puzzles: [Puzzle] = []) {
        self.puzzles = puzzles
    }
    
    func allPuzzles() -> [Puzzle] {
        return puzzles
    }
    
    func create(_ puzzle: Puzzle) {
        puzzles.append(puzzle)
    }
    
    func update(_ puzzle: Puzzle) {
        if let index = puzzles.firstIndex(where: { $0.id == puzzle.id }) {
            puzzles[index] = puzzle
        }
    }
    
    func delete(_ puzzle: Puzzle) {
        puzzles.removeAll { $0.id == puzzle.id }
    }
}

