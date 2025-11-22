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
    @Query(sort: \Puzzle.createdAt, order: .reverse) private var puzzles: [Puzzle]
    @Environment(\.modelContext) private var modelContext
    @State private var showCreatePuzzle = false
    @ObserveInjection private var inject
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                // Main content
                if puzzles.isEmpty {
                    EmptyStateView()
                } else {
                    List {
                        ForEach(puzzles) { puzzle in
                            NavigationLink(value: puzzle) {
                                PuzzleRowView(puzzle: puzzle)
                            }
                        }
                        .onDelete(perform: deletePuzzles)
                    }
                    .listStyle(.plain)
                }
                
                // Floating create button
                NavigationLink(value: "create") {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(.tint)
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                }
                .padding(24)
            }
            .navigationTitle("iykyk")
            .navigationDestination(for: Puzzle.self) { puzzle in
                PuzzleCreationView(puzzle: puzzle)
            }
            .navigationDestination(for: String.self) { value in
                if value == "create" {
                    PuzzleCreationView()
                }
            }
        }
        .enableInjection()
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

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "square.grid.4x4")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("No Puzzles Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Tap the + button to create your first puzzle")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct PuzzleRowView: View {
    let puzzle: Puzzle
    
    private var sequenceText: String {
        if let number = puzzle.sequenceNumber, number > 0 {
            return "#\(number)"
        } else {
            return "#?"
        }
    }
    
    private var wordCount: Int {
        puzzle.groups.flatMap { $0.words }.filter {
            !$0.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }.count
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(sequenceText)
                .font(.headline)
            
            HStack {
                Text("\(wordCount)/16 words")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Text(dateFormatter.string(from: puzzle.createdAt))
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    PuzzleLibraryView()
        .modelContainer(for: Puzzle.self, inMemory: true)
}
