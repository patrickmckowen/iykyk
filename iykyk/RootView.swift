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
    @State private var selectedMode: LibraryMode = .create
    @ObserveInjection private var inject
    
    var body: some View {
        NavigationStack {
            // Switch between library modes based on selection
            Group {
                switch selectedMode {
                case .create:
                    PuzzleLibraryView(mode: .create)
                case .play:
                    PuzzleLibraryView(mode: .play)
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Picker("Mode", selection: $selectedMode) {
                        Text("Create").tag(LibraryMode.create)
                        Text("Play").tag(LibraryMode.play)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 200)
                }
            }
            .toolbarBackground(.regularMaterial, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationDestination(for: Puzzle.self) { puzzle in
                if selectedMode == .create {
                    PuzzleCreationView(puzzle: puzzle)
                } else {
                    PuzzlePlayView(puzzle: puzzle)
                }
            }
            .navigationDestination(for: String.self) { value in
                if value == "create" {
                    PuzzleCreationView()
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

