//
//  PuzzleCreationView.swift
//  iykyk
//
//  Created by Patrick McKowen on 11/19/25.
//

import SwiftUI

struct PuzzleCreationView: View {
    @State private var puzzle: Puzzle
    @FocusState private var focusedField: FocusField?
    
    enum FocusField: Hashable {
        case title
        case word(groupIndex: Int, wordIndex: Int)
    }
    
    init(puzzle: Puzzle? = nil) {
        _puzzle = State(initialValue: puzzle ?? PuzzleFixtures.sampleEmptyPuzzle())
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Fixed-height title field
            TextField("Puzzle Title", text: $puzzle.title)
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .padding()
                .focused($focusedField, equals: .title)
            
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
            
            // Fixed-height actions
            BottomActionsView()
        }
        .frame(maxHeight: .infinity)
        .navigationTitle("New Puzzle")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    // Action placeholder
                }
            }
        }
    }
}

struct BottomActionsView: View {
    var body: some View {
        HStack(spacing: 12) {
            Button("Save Draft") {
                // Action placeholder
            }
            .buttonStyle(.bordered)
            .frame(maxWidth: .infinity)
            
            Button("Preview") {
                // Action placeholder
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity)
            .disabled(true) // Disabled for prototype
        }
        .padding()
        .background(Color(.systemBackground))
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

