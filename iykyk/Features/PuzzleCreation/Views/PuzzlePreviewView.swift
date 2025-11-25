//
//  PuzzlePreviewView.swift
//  iykyk
//
//  Created by AI on 11/22/25.
//

import SwiftUI
import UIKit
import SwiftData
import Inject

struct PuzzlePreviewView: View {
    let puzzle: Puzzle
    
    @State private var playSession: PuzzlePlaySession?
    @State private var validationIssues: [ValidationIssue] = []
    @State private var shakeAmount: CGFloat = 0
    @State private var shakingTileIDs: Set<UUID> = []
    @State private var showPublishedBanner = false
    
    @Namespace private var tileNamespace
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @ObserveInjection private var inject
    
    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 8), count: 4)
    }
    
    private var navigationTitle: String {
        if puzzle.isPublished, let number = puzzle.sequenceNumber {
            return "Puzzle #\(number)"
        }
        return "Preview"
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Published banner
            if showPublishedBanner {
                publishedBannerView
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            if let session = playSession {
                // Game state indicator
                if session.state != .inProgress {
                    gameOverBanner(for: session.state)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                // Solved groups section
                if !session.solvedTiles.isEmpty {
                    solvedGroupsView(session: session)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                // Active tiles grid
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(session.activeTiles) { tile in
                        GameTileButton(
                            text: tile.text,
                            isSelected: session.selectedTileIDs.contains(tile.id),
                            isShaking: shakingTileIDs.contains(tile.id),
                            shakeAmount: shakeAmount,
                            isDisabled: session.state != .inProgress,
                            namespace: tileNamespace,
                            tileID: tile.id,
                            onTap: {
                                playSession?.toggleSelection(for: tile.id)
                            }
                        )
                    }
                }
                .padding(.horizontal)
                
                // Controls
                VStack(spacing: 16) {
                    MistakesRemainingView(remaining: session.guessesRemaining)
                        .padding(.top, 8)
                    
                    GameControlsView(
                        canDeselect: !session.selectedTileIDs.isEmpty,
                        canSubmit: session.canSubmitGuess,
                        onShuffle: {
                            withAnimation {
                                session.shuffle()
                            }
                        },
                        onDeselectAll: {
                            session.clearSelection()
                        },
                        onSubmit: {
                            submitGuess()
                        }
                    )
                }
                .padding(.horizontal)
                
                Spacer()
            } else if !validationIssues.isEmpty {
                // Validation errors
                validationErrorsView
            } else {
                // Loading state
                ProgressView()
                    .padding()
            }
        }
        .padding(.top)
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(puzzle.isPublished ? "Published" : "Publish") {
                    publishPuzzle()
                }
                .disabled(playSession == nil || puzzle.isPublished)
            }
        }
        .onAppear {
            initializePlaySession()
        }
        .enableInjection()
    }
    
    private func initializePlaySession() {
        // Validate puzzle first
        validationIssues = PuzzleValidator.validate(puzzle)
        
        guard validationIssues.isEmpty else {
            playSession = nil
            return
        }
        
        // Create play session
        playSession = PuzzlePlaySession(puzzle: puzzle)
    }
    
    @ViewBuilder
    private func gameOverBanner(for state: PuzzlePlayState) -> some View {
        Group {
            switch state {
            case .won:
                Text("🎉 You solved it!")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.green)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                
            case .lost:
                Text("Game Over")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.red)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                
            case .inProgress:
                EmptyView()
            }
        }
    }
    
    @ViewBuilder
    private var publishedBannerView: some View {
        Text("✓ Puzzle Published")
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundStyle(.green)
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .background(Color.green.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal)
    }
    
    private func publishPuzzle() {
        guard !puzzle.isPublished else { return }
        
        // Set publish metadata
        puzzle.publishedAt = Date()
        puzzle.playStatus = .notStarted
        
        // Save to SwiftData
        do {
            try modelContext.save()
            
            // Show success banner briefly
            withAnimation {
                showPublishedBanner = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation {
                    showPublishedBanner = false
                }
            }
        } catch {
            print("Failed to publish puzzle: \(error)")
        }
    }
    
    @ViewBuilder
    private func solvedGroupsView(session: PuzzlePlaySession) -> some View {
        VStack(spacing: 8) {
            // Group solved tiles by their groupID
            let groupedTiles = Dictionary(grouping: session.solvedTiles) { $0.groupID }
            
            // Iterate in solve order (order they appear in solvedGroupIDs array)
            ForEach(session.solvedGroupIDs, id: \.self) { groupID in
                if let group = puzzle.groups.first(where: { $0.id == groupID }),
                   let tiles = groupedTiles[groupID] {
                    SolvedGroupRow(
                        title: group.title,
                        words: tiles.map { $0.text },
                        position: group.position
                    )
                    .background(
                        // Hidden tiles for matchedGeometryEffect
                        HStack(spacing: 0) {
                            ForEach(tiles) { tile in
                                Color.clear
                                    .matchedGeometryEffect(id: tile.id, in: tileNamespace)
                            }
                        }
                    )
                }
            }
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private var validationErrorsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
            .font(.system(size: 60))
            .foregroundStyle(.orange)
            
            Text("Puzzle Needs Fixes")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(validationIssues) { issue in
                    HStack(alignment: .top) {
                        Text("•")
                        Text(issue.message)
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)
            
            Text("Please return to editing and complete all groups.")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    private func submitGuess() {
        // Capture the selected tile IDs before submitting
        guard let session = playSession else { return }
        let guessedTileIDs = session.selectedTileIDs
        
        guard let result = session.submitGuess() else { return }

        switch result {
        case .correct:
            // Animate solved group
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                // Animation happens via state change in session
            }
            
        case .incorrect:
            // Store which tiles to shake
            shakingTileIDs = guessedTileIDs
            
            // Delay 300ms before starting shake animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                    shakeAmount = 2.0
                }
                
                // Reset shake after animation completes
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    shakeAmount = 0
                    shakingTileIDs.removeAll()
                    
                    // Apply penalty after shake completes
                    withAnimation {
                        session.applyIncorrectGuessPenalty()
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        PuzzlePreviewView(puzzle: PuzzleFixtures.sampleCompletedPuzzle())
    }
}
