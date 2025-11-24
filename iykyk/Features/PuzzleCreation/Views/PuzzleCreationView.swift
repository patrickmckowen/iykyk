//
//  PuzzleCreationView.swift
//  iykyk
//
//  Created by Patrick McKowen on 11/19/25.
//

import SwiftUI
import SwiftData
import Inject

enum PuzzleCreationFocusField: Hashable {
    case groupName(groupIndex: Int)
    case word(groupIndex: Int, wordIndex: Int)
}

struct PuzzleCreationView: View {
    @Bindable var puzzle: Puzzle
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: PuzzleCreationFocusField?
    @State private var isShowingPreview: Bool = false
    
    private let isNewPuzzle: Bool
    @State private var hasBeenInserted: Bool = false
    @ObserveInjection private var inject
    
    init(puzzle: Puzzle? = nil) {
        if let existingPuzzle = puzzle {
            self.puzzle = existingPuzzle
            self.isNewPuzzle = false
            self._hasBeenInserted = State(initialValue: true)
        } else {
            self.puzzle = PuzzleFixtures.sampleEmptyPuzzle()
            self.isNewPuzzle = true
            self._hasBeenInserted = State(initialValue: false)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            NavigationLink(
                destination: PuzzlePreviewView(puzzle: puzzle),
                isActive: $isShowingPreview
            ) {
                EmptyView()
            }
            .hidden()

            // Flexible scrollable content
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(puzzle.groups.sorted(by: { $0.position < $1.position })) { group in
                        GroupRowView(
                            group: group,
                            focusedField: $focusedField
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.top)
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
        .navigationTitle(isNewPuzzle ? "New Puzzle" : "Edit Puzzle")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Next") {
                    isShowingPreview = true
                }
                .disabled(!hasContent)
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
        .onAppear {
            // Insert new puzzle into context on first appearance
            if isNewPuzzle && !hasBeenInserted {
                modelContext.insert(puzzle)
                hasBeenInserted = true
            }
        }
        .onChange(of: puzzle.groups) { oldValue, newValue in
            // Autosave when groups change
            saveChanges()
        }
        .onDisappear {
            // Final save when leaving the view
            saveChanges()
        }
        .enableInjection()
    }
    
    private var hasContent: Bool {
        // Check if puzzle has any non-empty words
        return puzzle.groups.contains { group in
            group.words.contains { !$0.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        }
    }
    
    private func saveChanges() {
        guard hasBeenInserted else { return }
        
        do {
            try modelContext.save()
        } catch {
            print("Failed to save puzzle: \(error)")
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
        case .groupName(_):
            // Group names are not part of keyboard navigation chain
            break
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
        case .groupName(_):
            // Group names are not part of keyboard navigation chain
            break
        }
    }
}

#Preview {
    NavigationStack {
        PuzzleCreationView()
    }
    .modelContainer(for: Puzzle.self, inMemory: true)
}
