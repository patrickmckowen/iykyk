//
//  GroupRowView.swift
//  iykyk
//
//  Created by Patrick McKowen on 11/19/25.
//

import SwiftUI

struct GroupRowView: View {
    @Bindable var group: PuzzleGroup
    @FocusState.Binding var focusedField: PuzzleCreationFocusField?
    
    private var isGroupNameFocused: Bool {
        if case .groupName(let index) = focusedField {
            return index == group.position
        }
        return false
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Group name TextField with animated scaling
            TextField("Group \(group.position + 1)", text: $group.title)
                .font(isGroupNameFocused ? .title3 : .subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 4)
                .focused($focusedField, equals: .groupName(groupIndex: group.position))
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isGroupNameFocused)
                .submitLabel(.done)
                .onSubmit {
                    focusedField = nil
                }
            
            // 4 word tiles in a row
            HStack(spacing: 8) {
                ForEach(group.words.sorted(by: { $0.position < $1.position })) { word in
                    EditableWordTile(
                        text: Binding(
                            get: { word.text },
                            set: { word.text = $0 }
                        ),
                        focusedField: $focusedField,
                        fieldID: .word(groupIndex: group.position, wordIndex: word.position)
                    )
                }
            }
        }
    }
}

#Preview("Empty Group") { @MainActor in
    @Previewable @FocusState var focusedField: PuzzleCreationFocusField?
    
    let words = (0...3).map { PuzzleWord(text: "", position: $0) }
    let group = PuzzleGroup(title: "", position: 0, words: words)
    
    GroupRowView(
        group: group,
        focusedField: $focusedField
    )
    .padding()
}

#Preview("Filled Group") { @MainActor in
    @Previewable @FocusState var focusedField: PuzzleCreationFocusField?
    
    let words = [
        PuzzleWord(text: "LATTE", position: 0),
        PuzzleWord(text: "MOCHA", position: 1),
        PuzzleWord(text: "ESPRESSO", position: 2),
        PuzzleWord(text: "CAPPUCCINO", position: 3)
    ]
    let group = PuzzleGroup(title: "Coffee Drinks", position: 0, words: words)
    
    GroupRowView(
        group: group,
        focusedField: $focusedField
    )
    .padding()
}

#Preview("Mixed Content") { @MainActor in
    @Previewable @FocusState var focusedField: PuzzleCreationFocusField?
    
    let words = [
        PuzzleWord(text: "PYTHON", position: 0),
        PuzzleWord(text: "SWIFT", position: 1),
        PuzzleWord(text: "", position: 2),
        PuzzleWord(text: "", position: 3)
    ]
    let group = PuzzleGroup(title: "Programming Languages", position: 1, words: words)
    
    GroupRowView(
        group: group,
        focusedField: $focusedField
    )
    .padding()
}

