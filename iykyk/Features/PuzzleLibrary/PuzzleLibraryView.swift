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
            
            Text(mode == .create ? "Tap the + button in the toolbar to create your first puzzle" : "Publish a puzzle from Create mode to play it here")
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
