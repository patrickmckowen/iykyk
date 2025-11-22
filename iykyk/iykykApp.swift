//
//  iykykApp.swift
//  iykyk
//
//  Created by Patrick McKowen on 11/16/25.
//

import SwiftUI
import SwiftData

@main
struct iykykApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Puzzle.self,
            PuzzleGroup.self,
            PuzzleWord.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            
            // Backfill sequence numbers for any existing puzzles that don't have one,
            // and ensure the next sequence number stored in UserDefaults is ahead of them.
            let context = container.mainContext
            let descriptor = FetchDescriptor<Puzzle>(
                sortBy: [SortDescriptor(\.createdAt, order: .forward)]
            )
            
            if let existingPuzzles = try? context.fetch(descriptor) {
                var nextSequence = 1
                
                for puzzle in existingPuzzles {
                    if let stored = puzzle.sequenceNumber, stored > 0 {
                        nextSequence = max(nextSequence, stored + 1)
                    } else {
                        puzzle.sequenceNumber = nextSequence
                        nextSequence += 1
                    }
                }
                
                if context.hasChanges {
                    try? context.save()
                }
                
                PuzzleNumberingService.ensureNextSequenceNumber(atLeast: nextSequence)
            }
            
            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(sharedModelContainer)
    }
}
