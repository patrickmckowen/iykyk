//
//  PuzzleRepository.swift
//  iykyk
//
//  Created by Patrick McKowen on 11/18/25.
//

import Foundation

protocol PuzzleRepository {
    func allPuzzles() -> [Puzzle]
    func create(_ puzzle: Puzzle)
    func update(_ puzzle: Puzzle)
    func delete(_ puzzle: Puzzle)
}

