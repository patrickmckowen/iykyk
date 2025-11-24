//
//  PuzzleLibraryView.swift
//  iykyk
//
//  Created by Patrick McKowen on 11/21/25.
//

import SwiftUI
import SwiftData
import Inject

enum LibraryMode {
    case create
    case play
}

struct PuzzleLibraryView: View {
    var mode: LibraryMode = .create
    
    @Query(sort: \Puzzle.createdAt, order: .reverse) private var puzzles: [Puzzle]
    @Environment(\.modelContext) private var modelContext
    @State private var showCreatePuzzle = false
    @ObserveInjection private var inject
    
    private var displayedPuzzles: [Puzzle] {
        switch mode {
        case .create:
            return puzzles
        case .play:
            return puzzles.filter { $0.isPublished }
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Main content
            if displayedPuzzles.isEmpty {
                EmptyStateView(mode: mode)
            } else {
                List {
                    ForEach(displayedPuzzles) { puzzle in
                        NavigationLink(value: puzzle) {
                            PuzzleRowView(puzzle: puzzle, showPlayStatus: mode == .play)
                        }
                    }
                    .onDelete(perform: mode == .create ? deletePuzzles : nil)
                }
                .listStyle(.plain)
            }
            
            // Floating create button (only in Create mode)
            if mode == .create {
                NavigationLink(value: "create") {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(.tint)
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                }
                .padding(24)
            }
        }
        .navigationTitle(mode == .create ? "Create" : "Play")
        .enableInjection()
    }
    
    private func deletePuzzles(at offsets: IndexSet) {
        for index in offsets {
            let puzzle = displayedPuzzles[index]
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
    var mode: LibraryMode = .create
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "square.grid.4x4")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text(mode == .create ? "No Puzzles Yet" : "No Published Puzzles")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(mode == .create ? "Tap the + button to create your first puzzle" : "Publish a puzzle from Create mode to play it here")
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
    var showPlayStatus: Bool = false
    
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
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .center, spacing: 8) {
                Text(sequenceText)
                    .font(.headline)
                
                // Status capsule
                Text(showPlayStatus ? puzzle.playStatus.displayText : puzzle.publishStatusText)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(statusColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(statusColor.opacity(0.15))
                    .clipShape(Capsule())
            }
            
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
    
    private var statusColor: Color {
        if showPlayStatus {
            switch puzzle.playStatus {
            case .notStarted: return .blue
            case .inProgress: return .orange
            case .won: return .green
            case .lost: return .red
            }
        } else {
            return puzzle.isPublished ? .green : .secondary
        }
    }
}

#Preview {
    PuzzleLibraryView()
        .modelContainer(for: Puzzle.self, inMemory: true)
}
