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
    @State private var createNavigationPath = NavigationPath()
    
    var body: some View {
        TabView {
            Tab("Create", systemImage: "scribble.variable") {
                NavigationStack(path: $createNavigationPath) {
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
        .onReceive(NotificationCenter.default.publisher(for: .puzzlePublished)) { _ in
            // Pop navigation stack to root
            createNavigationPath = NavigationPath()
        }
        .enableInjection()
    }
}

#Preview {
    RootView()
        .modelContainer(try! PreviewSampleData.seededContainer())
}
