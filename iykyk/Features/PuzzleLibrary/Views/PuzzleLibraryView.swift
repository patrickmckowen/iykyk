//
//  PuzzleLibraryView.swift
//  iykyk
//
//  Created by Patrick McKowen on 11/21/25.
//

import SwiftUI
import SwiftData
import Inject

/// Filter options for the Create tab
enum CreateFilter: String, CaseIterable {
    case drafts = "Drafts"
    case published = "Published"
}

struct PuzzleLibraryView: View {
    var mode: LibraryMode = .create
    
    @Query(sort: \Puzzle.createdAt, order: .reverse) private var puzzles: [Puzzle]
    @Environment(\.modelContext) private var modelContext
    @ObserveInjection private var inject
    
    @State private var createFilter: CreateFilter = .drafts
    
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
    
    // MARK: - Computed Properties
    
    private var draftPuzzles: [Puzzle] {
        puzzles.filter { !$0.isPublished }
    }
    
    private var publishedPuzzlesForCreate: [Puzzle] {
        puzzles.filter { $0.isPublished }
    }
    
    private var filteredPuzzles: [Puzzle] {
        switch createFilter {
        case .drafts:
            return draftPuzzles
        case .published:
            return publishedPuzzlesForCreate
        }
    }
    
    // MARK: - Create Mode Body
    
    @ViewBuilder
    private var createModeBody: some View {
        VStack(spacing: 0) {
            // Segmented Picker
            Picker("Filter", selection: $createFilter) {
                ForEach(CreateFilter.allCases, id: \.self) { filter in
                    Text(filter.rawValue).tag(filter)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
            // Content
            if filteredPuzzles.isEmpty {
                createEmptyStateView
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredPuzzles) { puzzle in
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
    }
    
    @ViewBuilder
    private var createEmptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: createFilter == .drafts ? "square.and.pencil" : "checkmark.circle")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text(createFilter == .drafts ? "No Drafts" : "No Published Puzzles")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(createFilter == .drafts 
                 ? "Tap the + button to create your first puzzle"
                 : "Publish a draft to see it here")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
