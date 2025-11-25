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
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(puzzles) { puzzle in
                        NavigationLink(value: puzzle) {
                            PuzzleCard(puzzle: puzzle, showPlayStatus: false)
                        }
                        .buttonStyle(PuzzleCardButtonStyle())
                        .contextMenu {
                            Button(role: .destructive) {
                                deletePuzzle(puzzle)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
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
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(publishedPuzzles) { puzzle in
                        NavigationLink(value: puzzle) {
                            PuzzleCard(puzzle: puzzle, showPlayStatus: true)
                        }
                        .buttonStyle(PuzzleCardButtonStyle())
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
        }
    }
    
    private func deletePuzzle(_ puzzle: Puzzle) {
        modelContext.delete(puzzle)
        
        do {
            try modelContext.save()
        } catch {
            print("Failed to delete puzzle: \(error)")
        }
    }
}

#Preview {
    NavigationStack {
        PuzzleLibraryView(mode: .create)
    }
    .modelContainer(try! PreviewSampleData.seededContainer())
}
