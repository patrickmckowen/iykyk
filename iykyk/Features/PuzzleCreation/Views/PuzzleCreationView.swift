//
//  PuzzleCreationView.swift
//  iykyk
//
//  Created by Patrick McKowen on 11/19/25.
//

import SwiftUI
import SwiftData
import Inject

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
            // Flexible scrollable content
            ScrollView {
                ScrollViewReader { proxy in
                    VStack(spacing: 16) {
                        ForEach(puzzle.groups.sorted(by: { $0.position < $1.position })) { group in
                            GroupRowView(
                                group: group,
                                focusedField: $focusedField
                            )
                            .id(group.position)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    .padding(.bottom, 100) // Space for bottom actions
                    .onChange(of: focusedField) { _, newValue in
                        guard let groupIndex = newValue?.groupIndex else { return }
                        withAnimation(.easeInOut(duration: 0.3)) {
                            proxy.scrollTo(groupIndex, anchor: .center)
                        }
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .disabled(puzzle.isPublished)
            
            Spacer()
        }
        .frame(maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
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
        .navigationDestination(isPresented: $isShowingPreview) {
            PuzzlePreviewView(puzzle: puzzle)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Next") {
                    isShowingPreview = true
                }
                .disabled(!hasContent)
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
    
}

#Preview {
    NavigationStack {
        PuzzleCreationView()
    }
    .modelContainer(for: Puzzle.self, inMemory: true)
}
