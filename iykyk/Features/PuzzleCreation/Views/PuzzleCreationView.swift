//
//  PuzzleCreationView.swift
//  iykyk
//
//  Created by Patrick McKowen on 11/19/25.
//

import SwiftUI

enum PuzzleCreationFocusField: Hashable, Sendable {
    case word(groupIndex: Int, wordIndex: Int)
}

struct PuzzleCreationView: View {
    @State private var puzzle: Puzzle
    @FocusState private var focusedField: PuzzleCreationFocusField?
    
    init(puzzle: Puzzle? = nil) {
        _puzzle = State(initialValue: puzzle ?? PuzzleFixtures.sampleEmptyPuzzle())
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Flexible scrollable content
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(puzzle.groups.sorted(by: { $0.position < $1.position })) { group in
                        CategoryRowView(
                            group: group,
                            focusedField: $focusedField
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 100) // Space for bottom actions
            }
            .scrollDismissesKeyboard(.interactively)
            
            Spacer()
        }
        .frame(maxHeight: .infinity)
        .background(
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    focusedField = nil
                }
        )
        .navigationTitle("New Puzzle")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Next") {
                    // Action placeholder
                }
            }
            
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                
                Button(action: moveToPreviousField) {
                    Image(systemName: "chevron.up")
                }
                .disabled(focusedField == nil || (focusedField == .word(groupIndex: 0, wordIndex: 0)))
                
                Button(action: moveToNextField) {
                    Image(systemName: "chevron.down")
                }
                .disabled(isLastField)
            }
        }
    }
    
    private var isLastField: Bool {
        if case .word(let g, let w) = focusedField {
            return g == 3 && w == 3
        }
        return false
    }
    
    private func moveToPreviousField() {
        guard let current = focusedField else { return }
        
        switch current {
        case .word(let g, let w):
            if w > 0 {
                focusedField = .word(groupIndex: g, wordIndex: w - 1)
            } else if g > 0 {
                focusedField = .word(groupIndex: g - 1, wordIndex: 3)
            }
            // If at first field (0, 0), do nothing
        }
    }
    
    private func moveToNextField() {
        guard let current = focusedField else {
            focusedField = .word(groupIndex: 0, wordIndex: 0)
            return
        }
        
        switch current {
        case .word(let g, let w):
            if w < 3 {
                focusedField = .word(groupIndex: g, wordIndex: w + 1)
            } else if g < 3 {
                focusedField = .word(groupIndex: g + 1, wordIndex: 0)
            }
            // If last field, do nothing (button disabled)
        }
    }
}

#Preview("Empty Puzzle") {
    NavigationStack {
        PuzzleCreationView(puzzle: PuzzleFixtures.sampleEmptyPuzzle())
    }
}

#Preview("Partial Puzzle") {
    NavigationStack {
        PuzzleCreationView(puzzle: PuzzleFixtures.samplePartialPuzzle())
    }
}

#Preview("Completed Puzzle") {
    NavigationStack {
        PuzzleCreationView(puzzle: PuzzleFixtures.sampleCompletedPuzzle())
    }
}
