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
            Tab("Create", systemImage: "scribble.variable") {
                NavigationStack {
                    PuzzleLibraryView(mode: .create)
                        .navigationDestination(for: Puzzle.self) { puzzle in
                            if puzzle.isPublished {
                                PuzzlePreviewView(puzzle: puzzle)
                            } else {
                                PuzzleCreationView(puzzle: puzzle)
                            }
                        }
                        .navigationDestination(for: String.self) { value in
                            if value == "create" {
                                PuzzleCreationView()
                            }
                        }
                }
            }
            
            Tab("Play", systemImage: "xmark.triangle.circle.square") {
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
        .modelContainer(try! PreviewSampleData.seededContainer())
}
