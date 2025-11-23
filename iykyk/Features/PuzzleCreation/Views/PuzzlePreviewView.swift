//
//  PuzzlePreviewView.swift
//  iykyk
//
//  Created by AI on 11/22/25.
//

import SwiftUI
import Inject

struct PuzzlePreviewView: View {
    let puzzle: Puzzle
    
    @State private var playSession: PuzzlePlaySession?
    @State private var validationIssues: [ValidationIssue] = []
    @State private var shakeAmount: CGFloat = 0
    @State private var shakingTileIDs: Set<UUID> = []
    
    @Namespace private var tileNamespace
    @Environment(\.dismiss) private var dismiss
    @ObserveInjection private var inject
    
    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 8), count: 4)
    }
    
    var body: some View {
        VStack(spacing: 8) {
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
                        tileView(for: tile, session: session)
                    }
                }
                .padding(.horizontal)
                
                // Controls
                VStack(spacing: 8) {
                    Text("Guesses left: \(session.guessesRemaining)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Button(action: submitGuess) {
                        Text("Submit")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(session.canSubmitGuess ? Color.accentColor : Color.accentColor.opacity(0.4))
                            .foregroundStyle(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .disabled(!session.canSubmitGuess)
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
        .navigationTitle("Preview")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Publish") {
                    // No-op for now
                }
                .disabled(playSession == nil)
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
    private func solvedGroupsView(session: PuzzlePlaySession) -> some View {
        VStack(spacing: 8) {
            // Group solved tiles by their groupID
            let groupedTiles = Dictionary(grouping: session.solvedTiles) { $0.groupID }
            
            // Iterate in solve order (order they appear in solvedGroupIDs array)
            ForEach(session.solvedGroupIDs, id: \.self) { groupID in
                if let group = puzzle.groups.first(where: { $0.id == groupID }),
                   let tiles = groupedTiles[groupID] {
                    solvedGroupRow(group: group, tiles: tiles)
                }
            }
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private func solvedGroupRow(group: PuzzleGroup, tiles: [WordTile]) -> some View {
        let wordsList = tiles.map { $0.text }.joined(separator: ", ")
        
        VStack(spacing: 0) {
            Text(group.title.uppercased())
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white)
            
            Text(wordsList)
                .font(.system(size: 14))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
                .padding(.horizontal, 4)
                .background(
                    // Hidden tiles for matchedGeometryEffect
                    HStack(spacing: 0) {
                        ForEach(tiles) { tile in
                            Color.clear
                                .frame(maxWidth: .infinity)
                                .matchedGeometryEffect(id: tile.id, in: tileNamespace)
                        }
                    }
                )
        }
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity)
        .frame(maxHeight: .infinity)
        .background(GroupColors.color(for: group.position))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .aspectRatio(4.8, contentMode: .fit)
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
                }
            }
        }
    }
    
    @ViewBuilder
    private func tileView(for tile: WordTile, session: PuzzlePlaySession) -> some View {
        let isSelected = session.selectedTileIDs.contains(tile.id)
        let shouldShake = shakingTileIDs.contains(tile.id)
        
        Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                playSession?.toggleSelection(for: tile.id)
            }
        } label: {
            GeometryReader { geometry in
                Text(tile.text)
                    .font(.system(size: 14, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.primary)
                    .padding(4)
                    .frame(width: geometry.size.width, height: geometry.size.width)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(isSelected ? Color(.systemGray4) : Color(.systemGray6))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .strokeBorder(Color(.systemGray4), lineWidth: 1)
                            )
                    )
                    .matchedGeometryEffect(id: tile.id, in: tileNamespace)
            }
        }
        .buttonStyle(.plain)
        .aspectRatio(1, contentMode: .fit)
        .modifier(ShakeEffect(amount: shouldShake ? shakeAmount : 0))
        .disabled(session.state != .inProgress)
    }
}

// MARK: - Shake Effect

struct ShakeEffect: GeometryEffect {
    var amount: CGFloat
    
    var animatableData: CGFloat {
        get { amount }
        set { amount = newValue }
    }
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        let translation = sin(amount * .pi * 2) * 10
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}

#Preview {
    NavigationStack {
        PuzzlePreviewView(puzzle: PuzzleFixtures.sampleCompletedPuzzle())
    }
}


