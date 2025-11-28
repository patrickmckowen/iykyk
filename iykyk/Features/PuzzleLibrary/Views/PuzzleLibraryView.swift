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

/// Filter options for the Play tab
enum PlayFilter: String, CaseIterable {
    case toPlay = "To Play"
    case completed = "Completed"
}

struct PuzzleLibraryView: View {
    var mode: LibraryMode = .create
    
    @Query(sort: \Puzzle.createdAt, order: .reverse) private var puzzles: [Puzzle]
    @Environment(\.modelContext) private var modelContext
    @ObserveInjection private var inject
    
    @State private var createFilter: CreateFilter = .drafts
    @State private var playFilter: PlayFilter = .toPlay
    
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
    
    // MARK: - Play Mode Computed Properties
    
    private var publishedPuzzles: [Puzzle] {
        puzzles.filter { $0.isPublished }
    }
    
    private var toPlayPuzzles: [Puzzle] {
        publishedPuzzles.filter { $0.playStatus == .notStarted || $0.playStatus == .inProgress }
    }
    
    private var completedPuzzles: [Puzzle] {
        publishedPuzzles.filter { $0.playStatus == .won || $0.playStatus == .lost }
    }
    
    private var filteredPlayPuzzles: [Puzzle] {
        switch playFilter {
        case .toPlay:
            return toPlayPuzzles
        case .completed:
            return completedPuzzles
        }
    }
    
    // MARK: - Play Mode Body
    
    @ViewBuilder
    private var playModeBody: some View {
        if publishedPuzzles.isEmpty {
            EmptyStateView(mode: .play)
        } else {
            VStack(spacing: 0) {
                // Segmented Picker
                Picker("Filter", selection: $playFilter) {
                    ForEach(PlayFilter.allCases, id: \.self) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                
                // Content
                if filteredPlayPuzzles.isEmpty {
                    playEmptyStateView
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredPlayPuzzles) { puzzle in
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
        }
    }
    
    @ViewBuilder
    private var playEmptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: playFilter == .toPlay ? "play.circle" : "checkmark.circle")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text(playFilter == .toPlay ? "No Puzzles to Play" : "No Completed Puzzles")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(playFilter == .toPlay 
                 ? "All caught up! Publish more puzzles to play them here"
                 : "Complete a puzzle to see it here")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
