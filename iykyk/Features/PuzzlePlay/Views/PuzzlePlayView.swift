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
    
    // Lift animation state
    @State private var liftedTileIDs: Set<UUID> = []
    
    // Morph animation state
    @State private var morphingGroupID: UUID? = nil
    @State private var morphProgress: CGFloat = 0
    @State private var showMorphedRowText: Bool = true
    
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
            .padding(.horizontal, 8)
            
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
                    },
                    isLifted: liftedTileIDs.contains(tile.id),
                    morphColor: morphColorForTile(tile)
                )
            }
        }
        .padding(.horizontal, 8)
        
        // Controls
        VStack(spacing: 8) {
            MistakesRemainingView(remaining: session.guessesRemaining)
                .padding(.vertical, 16)
            
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
        .padding(.horizontal, 8)
        
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
                    .padding(.horizontal, 8)
                
            case .lost:
                Text("Better luck next time!")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.red)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 8)
                
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
                    .padding(.horizontal, 8)
                
            case .lost:
                Text("Game Over")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.red)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 8)
                
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
                    let isMorphing = morphingGroupID == groupID
                    SolvedGroupRow(
                        title: group.title,
                        words: tiles.map { $0.text },
                        position: group.position,
                        showText: isMorphing ? showMorphedRowText : true
                    )
                    .background(
                        // Hidden tiles for matchedGeometryEffect
                        HStack(spacing: 0) {
                            ForEach(tiles) { tile in
                                Color.clear
                                    .matchedGeometryEffect(id: tile.id, in: tileNamespace, isSource: true)
                            }
                        }
                    )
                }
            }
        }
        .padding(.horizontal, 8)
    }
    
    /// Returns the morph color for a tile if it's part of the morphing group
    private func morphColorForTile(_ tile: WordTile) -> Color? {
        guard let morphingGroupID,
              tile.groupID == morphingGroupID,
              morphProgress > 0 else {
            return nil
        }
        
        // Find the group position to get the correct color
        if let group = puzzle.groups.first(where: { $0.id == morphingGroupID }) {
            let groupColor = GroupColors.color(for: group.position)
            // Interpolate from selected gray to group color based on morphProgress
            return Color(.systemGray4).interpolate(to: groupColor, progress: morphProgress)
        }
        return nil
    }
    
    private func submitGuess() {
        guard let session = playSession else { return }
        let guessedTileIDs = session.selectedTileIDs
        
        // Phase 1: Lift tiles with staggered delays
        liftTiles(Array(guessedTileIDs)) {
            // After lift completes, check the guess
            guard let result = session.submitGuess() else { return }
            
            switch result {
            case .correct(let groupID, _):
                handleCorrectGuess(session: session, groupID: groupID, tileIDs: guessedTileIDs)
                
            case .incorrect:
                handleIncorrectGuess(session: session, tileIDs: guessedTileIDs)
            }
        }
    }
    
    /// Phase 1: Lift tiles with staggered animation
    private func liftTiles(_ tileIDs: [UUID], completion: @escaping () -> Void) {
        let shuffledIDs = tileIDs.shuffled()
        
        for (index, tileID) in shuffledIDs.enumerated() {
            let delay = Double(index) * 0.05 // 50ms stagger
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                    _ = liftedTileIDs.insert(tileID)
                }
            }
        }
        
        // Complete after all tiles lifted
        let totalLiftDuration = Double(tileIDs.count) * 0.05 + 0.15
        DispatchQueue.main.asyncAfter(deadline: .now() + totalLiftDuration) {
            completion()
        }
    }
    
    /// Handle correct guess: morph tiles into solved row
    private func handleCorrectGuess(session: PuzzlePlaySession, groupID: UUID, tileIDs: Set<UUID>) {
        // Start morph sequence - hide the solved row text initially
        showMorphedRowText = false
        morphingGroupID = groupID
        
        // Animate morph progress (tile color transition)
        withAnimation(.easeInOut(duration: 0.3)) {
            morphProgress = 1.0
        }
        
        // After color transition, trigger position animation via matchedGeometryEffect
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                // Clear lifted state - tiles will animate to solved row position
                liftedTileIDs.removeAll()
            }
            
            // Sync solved group to puzzle
            if let group = puzzle.groups.first(where: { $0.id == groupID }) {
                puzzle.solvedGroupPositions.insert(group.position)
            }
        }
        
        // After position animation, fade in solved row text
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            withAnimation(.easeInOut(duration: 0.25)) {
                showMorphedRowText = true
            }
        }
        
        // Clean up morph state
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            morphingGroupID = nil
            morphProgress = 0
            
            // Check if game is won and persist
            if session.state == .won {
                puzzle.playStatus = .won
            }
            saveContext()
        }
    }
    
    /// Handle incorrect guess: shake and lower tiles
    private func handleIncorrectGuess(session: PuzzlePlaySession, tileIDs: Set<UUID>) {
        shakingTileIDs = tileIDs
        
        // Start shake animation
        withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
            shakeAmount = 2.0
        }
        
        // After shake, lower tiles and apply penalty
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            // Reset shake
            shakeAmount = 0
            shakingTileIDs.removeAll()
            
            // Lower tiles
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

