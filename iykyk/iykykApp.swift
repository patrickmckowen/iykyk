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
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
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
