//
//  RootView.swift
//  iykyk
//
//  Created by Patrick McKowen on 11/18/25.
//

import SwiftUI
import SwiftData
import Inject

struct RootView: View {
    @ObserveInjection private var inject
    
    var body: some View {
        TabView {
            Tab("Create", systemImage: "square.grid.2x2") {
                NavigationStack {
                    PuzzleLibraryView(mode: .create)
                        .navigationDestination(for: Puzzle.self) { puzzle in
                            PuzzleCreationView(puzzle: puzzle)
                        }
                        .navigationDestination(for: String.self) { value in
                            if value == "create" {
                                PuzzleCreationView()
                            }
                        }
                }
            }
            
            Tab("Play", systemImage: "play.fill") {
                NavigationStack {
                    PuzzleLibraryView(mode: .play)
                        .navigationDestination(for: Puzzle.self) { puzzle in
                            PuzzlePlayView(puzzle: puzzle)
                        }
                }
            }
        }
        .enableInjection()
    }
}

#Preview {
    RootView()
        .modelContainer(for: Puzzle.self, inMemory: true)
}
