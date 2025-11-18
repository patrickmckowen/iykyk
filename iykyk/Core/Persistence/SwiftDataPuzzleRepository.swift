//
//  SwiftDataPuzzleRepository.swift
//  iykyk
//
//  Created by Patrick McKowen on 11/18/25.
//

import Foundation
import SwiftData

@Observable
final class SwiftDataPuzzleRepository: PuzzleRepository {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func allPuzzles() -> [Puzzle] {
        let descriptor = FetchDescriptor<Puzzle>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    func create(_ puzzle: Puzzle) {
        modelContext.insert(puzzle)
        try? modelContext.save()
    }
    
    func update(_ puzzle: Puzzle) {
        // SwiftData automatically tracks changes to @Model objects
        try? modelContext.save()
    }
    
    func delete(_ puzzle: Puzzle) {
        modelContext.delete(puzzle)
        try? modelContext.save()
    }
}

