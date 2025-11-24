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
            
            // Backfill sequence numbers for any existing puzzles that don't have one
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
            // Log the error for debugging
            print("ModelContainer creation failed: \(error)")
            
            // Check if it's a schema incompatibility error
            let nsError = error as NSError
            if nsError.domain == "NSCocoaErrorDomain" && (nsError.code == 134110 || nsError.code == 134140) {
                print("Schema migration error detected. Attempting store reset...")
                
                // Delete the existing store files for a fresh start
                let fileManager = FileManager.default
                if let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
                    // Find and delete all SwiftData store files
                    if let files = try? fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil) {
                        for fileURL in files {
                            let ext = fileURL.pathExtension
                            if ext == "sqlite" || ext == "sqlite-shm" || ext == "sqlite-wal" {
                                try? fileManager.removeItem(at: fileURL)
                                print("Deleted: \(fileURL.lastPathComponent)")
                            }
                        }
                    }
                }
                
                // Try again with a fresh store
                do {
                    let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
                    print("Store reset successful. Starting with fresh database.")
                    return container
                } catch {
                    fatalError("Could not create ModelContainer even after reset: \(error)")
                }
            }
            
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
