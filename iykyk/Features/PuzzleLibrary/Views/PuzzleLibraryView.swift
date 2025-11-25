//
//  PuzzleLibraryView.swift
//  iykyk
//
//  Created by Patrick McKowen on 11/21/25.
//

import SwiftUI
import SwiftData
import Inject

struct PuzzleLibraryView: View {
    var mode: LibraryMode = .create
    
    @Query(sort: \Puzzle.createdAt, order: .reverse) private var puzzles: [Puzzle]
    @Environment(\.modelContext) private var modelContext
    @State private var showCreatePuzzle = false
    @ObserveInjection private var inject
    
    var body: some View {
        ZStack {
            if mode == .create {
                createModeBody
            } else {
                playModeBody
            }
        }
        .navigationTitle(mode == .create ? "Create" : "Play")
        .toolbar {
            if mode == .create {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(value: "create") {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .enableInjection()
    }
    
    @ViewBuilder
    private var createModeBody: some View {
        if puzzles.isEmpty {
            EmptyStateView(mode: .create)
        } else {
            List {
                ForEach(puzzles) { puzzle in
                    NavigationLink(value: puzzle) {
                        PuzzleRowView(puzzle: puzzle, showPlayStatus: false)
                    }
                }
                .onDelete(perform: deletePuzzles)
            }
            .listStyle(.plain)
        }
    }
    
    private var publishedPuzzles: [Puzzle] {
        puzzles.filter { $0.isPublished }
    }
    
    @ViewBuilder
    private var playModeBody: some View {
        if publishedPuzzles.isEmpty {
            EmptyStateView(mode: .play)
        } else {
            List {
                ForEach(publishedPuzzles) { puzzle in
                    NavigationLink(value: puzzle) {
                        PuzzleRowView(puzzle: puzzle, showPlayStatus: true)
                    }
                }
            }
            .listStyle(.plain)
        }
    }
    
    private func deletePuzzles(at offsets: IndexSet) {
        for index in offsets {
            let puzzle = puzzles[index]
            modelContext.delete(puzzle)
        }
        
        do {
            try modelContext.save()
        } catch {
            print("Failed to delete puzzle: \(error)")
        }
    }
}

#Preview {
    NavigationStack {
        PuzzleLibraryView()
    }
    .modelContainer(for: Puzzle.self, inMemory: true)
}

