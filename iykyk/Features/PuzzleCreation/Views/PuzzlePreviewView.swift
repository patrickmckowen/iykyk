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
    @State private var showIncorrectShake: Bool = false
    
    @Environment(\.dismiss) private var dismiss
    @ObserveInjection private var inject
    
    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 8), count: 4)
    }
    
    var body: some View {
        VStack(spacing: 16) {
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
                .modifier(ShakeEffect(shake: showIncorrectShake))
                
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
            let sortedGroupIDs = groupedTiles.keys.sorted { id1, id2 in
                // Sort by group position
                let group1 = puzzle.groups.first(where: { $0.id == id1 })
                let group2 = puzzle.groups.first(where: { $0.id == id2 })
                return (group1?.position ?? 0) < (group2?.position ?? 0)
            }
            
            ForEach(sortedGroupIDs, id: \.self) { groupID in
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
        VStack(spacing: 4) {
            Text(group.title.uppercased())
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(GroupColors.color(for: group.position))
            
            HStack(spacing: 4) {
                ForEach(tiles) { tile in
                    Text(tile.text)
                        .font(.system(size: 12, weight: .bold))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white)
                        .padding(8)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(GroupColors.color(for: group.position))
                        )
                }
            }
        }
        .padding(.vertical, 4)
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
        guard var session = playSession,
              let result = session.submitGuess() else { return }

        switch result {
        case .correct:
            // Animate solved group
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                // Animation happens via state change in session
            }
            
        case .incorrect:
            // Shake animation for incorrect guess
            withAnimation(.default) {
                showIncorrectShake = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showIncorrectShake = false
            }
        }

        // Write back mutated session so SwiftUI sees the change.
        playSession = session
    }
    
    @ViewBuilder
    private func tileView(for tile: WordTile, session: PuzzlePlaySession) -> some View {
        let isSelected = session.selectedTileIDs.contains(tile.id)
        
        Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                guard var currentSession = playSession else { return }
                currentSession.toggleSelection(for: tile.id)
                playSession = currentSession
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
            }
        }
        .buttonStyle(.plain)
        .aspectRatio(1, contentMode: .fit)
        .disabled(session.state != .inProgress)
    }
}

// MARK: - Shake Effect

struct ShakeEffect: GeometryEffect {
    var shake: Bool
    
    var animatableData: CGFloat {
        get { shake ? 1 : 0 }
        set { }
    }
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        let translation = shake ? sin(animatableData * .pi * 2) * 10 : 0
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}

#Preview {
    NavigationStack {
        PuzzlePreviewView(puzzle: PuzzleFixtures.sampleCompletedPuzzle())
    }
}


