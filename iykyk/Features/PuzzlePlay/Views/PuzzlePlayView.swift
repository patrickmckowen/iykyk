//
//  PuzzlePlayView.swift
//  iykyk
//
//  Created by AI Assistant on 11/24/25.
//

import SwiftUI
import SwiftData
import Inject

struct PuzzlePlayView: View {
    @Bindable var puzzle: Puzzle
    
    @State private var playSession: PuzzlePlaySession?
    @State private var shakeAmount: CGFloat = 0
    @State private var shakingTileIDs: Set<UUID> = []
    
    @Namespace private var tileNamespace
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @ObserveInjection private var inject
    
    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 8), count: 4)
    }
    
    private var navigationTitle: String {
        if let number = puzzle.sequenceNumber {
            return "Puzzle #\(number)"
        }
        return "Puzzle"
    }
    
    var body: some View {
        VStack(spacing: 8) {
            if puzzle.playStatus == .won || puzzle.playStatus == .lost {
                // End state view - show completed puzzle
                endStateView
            } else if let session = playSession {
                // Active gameplay
                gameplayView(session: session)
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
        .onAppear {
            initializePlaySession()
        }
        .enableInjection()
    }
    
    private func initializePlaySession() {
        // If already completed, don't create a new session
        if puzzle.playStatus == .won || puzzle.playStatus == .lost {
            return
        }
        
        // Mark as in progress if starting fresh
        if puzzle.playStatus == .notStarted {
            puzzle.playStatus = .inProgress
            saveContext()
        }
        
        // Create play session
        playSession = PuzzlePlaySession(puzzle: puzzle)
    }
    
    @ViewBuilder
    private var endStateView: some View {
        VStack(spacing: 16) {
            // Result banner
            resultBanner(for: puzzle.playStatus)
            
            // Show all groups in final state
            VStack(spacing: 8) {
                ForEach(puzzle.groups.sorted(by: { $0.position < $1.position })) { group in
                    SolvedGroupRow(
                        title: group.title,
                        words: group.words.map { $0.text },
                        position: group.position
                    )
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
    }
    
    @ViewBuilder
    private func gameplayView(session: PuzzlePlaySession) -> some View {
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
    }
    
    @ViewBuilder
    private func resultBanner(for status: PuzzlePlayStatus) -> some View {
        Group {
            switch status {
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
                Text("Better luck next time!")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.red)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                
            default:
                EmptyView()
            }
        }
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
    
    private func submitGuess() {
        // Capture the selected tile IDs before submitting
        guard let session = playSession else { return }
        let guessedTileIDs = session.selectedTileIDs
        
        guard let result = session.submitGuess() else { return }

        switch result {
        case .correct(let groupID, _):
            // Sync solved group to puzzle
            if let group = puzzle.groups.first(where: { $0.id == groupID }) {
                puzzle.solvedGroupPositions.insert(group.position)
            }
            
            // Animate solved group
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                // Animation happens via state change in session
            }
            
            // Check if game is won and persist
            if session.state == .won {
                puzzle.playStatus = .won
            }
            saveContext()
            
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
                        
                        // Sync guesses remaining to puzzle
                        puzzle.guessesRemaining = session.guessesRemaining
                        
                        // Check if game is lost and persist
                        if session.state == .lost {
                            puzzle.playStatus = .lost
                        }
                        saveContext()
                    }
                }
            }
        }
    }
    
    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
}

#Preview {
    NavigationStack {
        PuzzlePlayView(puzzle: PuzzleFixtures.sampleCompletedPuzzle())
    }
    .modelContainer(for: Puzzle.self, inMemory: true)
}

