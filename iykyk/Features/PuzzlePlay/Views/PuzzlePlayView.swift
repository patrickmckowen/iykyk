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
    
    // Animation state
    @State private var shakeAmount: CGFloat = 0
    @State private var shakingTileIDs: Set<UUID> = []
    @State private var liftedTileIDs: Set<UUID> = []
    
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
            if let session = playSession {
                gameplayView(session: session)
            } else if puzzle.playStatus == .won || puzzle.playStatus == .lost {
                // End state - create a session to show final grid
                endStateGrid
            } else {
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
        // Always create a session for completed puzzles to show the final grid
        if puzzle.playStatus == .won || puzzle.playStatus == .lost {
            playSession = PuzzlePlaySession(puzzle: puzzle)
            return
        }
        
        // Mark as in progress if starting fresh
        if puzzle.playStatus == .notStarted {
            puzzle.playStatus = .inProgress
            saveContext()
        }
        
        playSession = PuzzlePlaySession(puzzle: puzzle)
    }
    
    // MARK: - End State Grid
    
    @ViewBuilder
    private var endStateGrid: some View {
        VStack(spacing: 16) {
            resultBanner
            
            // Show all tiles in their final solved state (sorted by group position)
            let allTiles = puzzle.groups
                .sorted { $0.position < $1.position }
                .flatMap { group in
                    group.words.map { word in
                        (word: word, position: group.position)
                    }
                }
            
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(allTiles, id: \.word.id) { item in
                    GameTileButton(
                        text: item.word.text,
                        isSelected: false,
                        isShaking: false,
                        shakeAmount: 0,
                        isDisabled: true,
                        onTap: {},
                        groupDifficultyPosition: item.position
                    )
                }
            }
            .padding(.horizontal, 8)
            
            Spacer()
        }
    }
    
    // MARK: - Gameplay View
    
    @ViewBuilder
    private func gameplayView(session: PuzzlePlaySession) -> some View {
        // Result banner when game ends
        if session.state != .inProgress {
            resultBanner
                .transition(.move(edge: .top).combined(with: .opacity))
        }
        
        // Single 4x4 grid with all 16 tiles
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(session.orderedTiles) { tile in
                let isSolved = session.isTileSolved(tile.id)
                let difficultyPosition = session.groupDifficultyPosition(for: tile.id)
                
                GameTileButton(
                    text: tile.text,
                    isSelected: session.selectedTileIDs.contains(tile.id),
                    isShaking: shakingTileIDs.contains(tile.id),
                    shakeAmount: shakeAmount,
                    isDisabled: isSolved || session.state != .inProgress,
                    onTap: {
                        playSession?.toggleSelection(for: tile.id)
                    },
                    isLifted: liftedTileIDs.contains(tile.id),
                    groupDifficultyPosition: difficultyPosition
                )
            }
        }
        .padding(.horizontal, 8)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: session.orderedTiles.map(\.id))
        
        // Controls
        VStack(spacing: 8) {
            MistakesRemainingView(remaining: session.guessesRemaining)
                .padding(.vertical, 16)
            
            GameControlsView(
                canDeselect: !session.selectedTileIDs.isEmpty,
                canSubmit: session.canSubmitGuess,
                onShuffle: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
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
        .padding(.horizontal, 8)
        
        Spacer()
    }
    
    // MARK: - Result Banner
    
    @ViewBuilder
    private var resultBanner: some View {
        Group {
            if puzzle.playStatus == .won || playSession?.state == .won {
                Text("🎉 You solved it!")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.green)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 8)
            } else if puzzle.playStatus == .lost || playSession?.state == .lost {
                Text("Game Over")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.red)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 8)
            }
        }
    }
    
    // MARK: - Guess Handling
    
    private func submitGuess() {
        guard let session = playSession else { return }
        let guessedTileIDs = session.selectedTileIDs
        
        // Phase 1: Lift selected tiles
        liftTiles(Array(guessedTileIDs)) {
            // After lift, check the guess
            guard let result = session.submitGuess() else { return }
            
            switch result {
            case .correct(let groupID, _):
                handleCorrectGuess(session: session, groupID: groupID)
                
            case .incorrect:
                handleIncorrectGuess(session: session, tileIDs: guessedTileIDs)
            }
        }
    }
    
    /// Lift tiles with staggered animation
    private func liftTiles(_ tileIDs: [UUID], completion: @escaping () -> Void) {
        for (index, tileID) in tileIDs.enumerated() {
            let delay = Double(index) * 0.08
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                    _ = liftedTileIDs.insert(tileID)
                }
            }
        }
        
        let totalLiftDuration = Double(tileIDs.count) * 0.08 + 0.3
        DispatchQueue.main.asyncAfter(deadline: .now() + totalLiftDuration) {
            completion()
        }
    }
    
    /// Handle correct guess: tiles rearrange to top, change color
    private func handleCorrectGuess(session: PuzzlePlaySession, groupID: UUID) {
        // Animate tiles to their new positions and lower them
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            liftedTileIDs.removeAll()
            
            // Sync solved group to puzzle
            if let group = puzzle.groups.first(where: { $0.id == groupID }) {
                puzzle.solvedGroupPositions.insert(group.position)
            }
        }
        
        // Persist state after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if session.state == .won {
                puzzle.playStatus = .won
            }
            saveContext()
        }
    }
    
    /// Handle incorrect guess: shake and deselect tiles
    private func handleIncorrectGuess(session: PuzzlePlaySession, tileIDs: [UUID]) {
        shakingTileIDs = Set(tileIDs)
        
        // Start shake animation
        withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
            shakeAmount = 2.0
        }
        
        // After shake, lower tiles and apply penalty
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            shakeAmount = 0
            shakingTileIDs.removeAll()
            
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                liftedTileIDs.removeAll()
            }
            
            // Apply penalty after lower animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation {
                    session.applyIncorrectGuessPenalty()
                    puzzle.guessesRemaining = session.guessesRemaining
                    
                    if session.state == .lost {
                        puzzle.playStatus = .lost
                    }
                    saveContext()
                }
            }
        }
    }
    
    // MARK: - Persistence
    
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
