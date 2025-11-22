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
    
    @State private var tiles: [Tile] = []
    @State private var selectedTileIDs: Set<UUID> = []
    @State private var guessesRemaining: Int = 3
    
    @Environment(\.dismiss) private var dismiss
    @ObserveInjection private var inject
    
    private struct Tile: Identifiable {
        let id: UUID
        let text: String
        let groupID: UUID
    }
    
    private var baseTiles: [Tile] {
        puzzle.groups.flatMap { group in
            group.words.map { word in
                let trimmed = word.text.trimmingCharacters(in: .whitespacesAndNewlines)
                let displayText = trimmed.isEmpty ? "WORD" : trimmed
                return Tile(id: word.id, text: displayText, groupID: group.id)
            }
        }
    }
    
    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 8), count: 4)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(tiles) { tile in
                    tileView(for: tile)
                }
            }
            .padding(.horizontal)
            
            VStack(spacing: 8) {
                Text("Guesses left: \(guessesRemaining)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Button(action: submitGuess) {
                    Text("Submit")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(canSubmit ? Color.accentColor : Color.accentColor.opacity(0.4))
                        .foregroundStyle(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .disabled(!canSubmit)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding(.top)
        .navigationTitle("Preview")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Publish") {
                    // No-op for now
                }
            }
        }
        .onAppear {
            if tiles.isEmpty {
                tiles = baseTiles.shuffled()
            }
        }
        .enableInjection()
    }
    
    private var canSubmit: Bool {
        selectedTileIDs.count == 4 && guessesRemaining > 0
    }
    
    private func toggleSelection(for tile: Tile) {
        if selectedTileIDs.contains(tile.id) {
            selectedTileIDs.remove(tile.id)
        } else {
            guard selectedTileIDs.count < 4 else { return }
            selectedTileIDs.insert(tile.id)
        }
    }
    
    private func submitGuess() {
        guard canSubmit else { return }
        
        if guessesRemaining > 0 {
            guessesRemaining -= 1
        }
        
        withAnimation(.easeInOut(duration: 0.15)) {
            selectedTileIDs.removeAll()
        }
    }
    
    @ViewBuilder
    private func tileView(for tile: Tile) -> some View {
        let isSelected = selectedTileIDs.contains(tile.id)
        
        Button {
            toggleSelection(for: tile)
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
    }
}

#Preview {
    NavigationStack {
        PuzzlePreviewView(puzzle: PuzzleFixtures.sampleCompletedPuzzle())
    }
}


