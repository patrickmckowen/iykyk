//
//  PuzzlePreviewView.swift
//  iykyk
//
//  Created by AI on 11/22/25.
//

import SwiftUI
import UIKit
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
                VStack(spacing: 16) {
                    // Mistakes Remaining
                    HStack(spacing: 8) {
                        Text("Mistakes Remaining:")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        HStack(spacing: 6) {
                            ForEach(0..<4) { index in
                                Circle()
                                    .fill(index < session.guessesRemaining ? Color.primary.opacity(0.6) : Color.secondary.opacity(0.2))
                                    .frame(width: 12, height: 12)
                            }
                        }
                    }
                    .padding(.top, 8)
                    
                    // Action Buttons
                    HStack(spacing: 12) {
                        Button("Shuffle") {
                            withAnimation {
                                session.shuffle()
                            }
                        }
                        .buttonStyle(CapsuleButtonStyle())
                        
                        Button("Deselect All") {
                            session.clearSelection()
                        }
                        .buttonStyle(CapsuleButtonStyle())
                        .disabled(session.selectedTileIDs.isEmpty)
                        
                        Button("Submit") {
                            submitGuess()
                        }
                        .buttonStyle(CapsuleButtonStyle(isFilled: session.canSubmitGuess))
                        .disabled(!session.canSubmitGuess)
                    }
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
        }
        .frame(maxWidth: .infinity)
        .frame(height: 80)
        .background(GroupColors.color(for: group.position))
        .clipShape(RoundedRectangle(cornerRadius: 8))
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
                AutoSizingTileText(text: tile.text, containerSize: geometry.size)
                    .foregroundStyle(Color.primary)
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
        .frame(height: 80)
        .modifier(ShakeEffect(amount: shouldShake ? shakeAmount : 0))
        .disabled(session.state != .inProgress)
    }
}

struct CapsuleButtonStyle: ButtonStyle {
    var isFilled: Bool = false
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.colorScheme) private var colorScheme
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .semibold))
            .padding(.vertical, 10)
            .padding(.horizontal, 16)
            .foregroundStyle(textColor)
            .background(
                Capsule()
                    .fill(backgroundColor)
            )
            .overlay(
                Capsule()
                    .strokeBorder(borderColor, lineWidth: 1)
            )
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
    
    private var textColor: Color {
        if isFilled {
            return colorScheme == .dark ? .black : .white
        }
        return isEnabled ? .primary : .secondary
    }
    
    private var backgroundColor: Color {
        if isFilled {
            return .primary
        }
        return .clear
    }
    
    private var borderColor: Color {
        if isFilled {
            return .clear
        }
        return isEnabled ? .primary : .secondary.opacity(0.5)
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

private struct AutoSizingTileText: View {
    let text: String
    let containerSize: CGSize
    
    @State private var fontSize: CGFloat = 16
    
    // Visual constants
    private let minFontSize: CGFloat = 10
    private let maxFontSize: CGFloat = 14
    private let tilePadding: CGFloat = 4
    private let textHorizontalBuffer: CGFloat = 10
    
    var body: some View {
        Text(text)
            .font(.system(size: fontSize, weight: .bold))
            .multilineTextAlignment(.center)
            .padding(tilePadding)
            .frame(width: containerSize.width, height: containerSize.height)
            .onChange(of: containerSize) { _, newSize in
                updateFontSize(availableSize: newSize)
            }
            .onAppear {
                updateFontSize(availableSize: containerSize)
            }
    }
    
    private func updateFontSize(availableSize: CGSize) {
        let width = availableSize.width - (tilePadding * 2) - textHorizontalBuffer
        let height = availableSize.height - (tilePadding * 2)
        
        guard width > 0 && height > 0 else { return }
        
        if text.isEmpty {
            fontSize = 14 // Default size for placeholder
            return
        }
        
        if text.containsOnlyEmoji {
            fontSize = 22
            return
        }
        
        // Find best fit
        for size in stride(from: maxFontSize, through: minFontSize, by: -1) {
            let font = UIFont.systemFont(ofSize: size, weight: .bold)
            
            // 1. Check if any single word exceeds width
            let words = text.split(separator: " ")
            let maxWordWidth = words.map { word -> CGFloat in
                let attrString = NSAttributedString(string: String(word), attributes: [.font: font])
                return attrString.size().width
            }.max() ?? 0
            
            if maxWordWidth > width {
                continue
            }
            
            // 2. Check total bounds
            let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
            let attrString = NSAttributedString(string: text, attributes: [.font: font])
            let boundingBox = attrString.boundingRect(with: constraintRect,
                                                    options: .usesLineFragmentOrigin,
                                                    context: nil)
            
            if boundingBox.height <= height {
                fontSize = size
                return
            }
        }
        
        fontSize = minFontSize
    }
}

#Preview {
    NavigationStack {
        PuzzlePreviewView(puzzle: PuzzleFixtures.sampleCompletedPuzzle())
    }
}
