//
//  CategoryRowView.swift
//  iykyk
//
//  Created by Patrick McKowen on 11/19/25.
//

import SwiftUI

struct CategoryRowView: View {
    @Bindable var group: PuzzleGroup
    @FocusState.Binding var focusedField: PuzzleCreationView.FocusField?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Category label
            Text(categoryLabel)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 4)
            
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
    
    private var categoryLabel: String {
        if group.title.isEmpty {
            return "Category \(group.position + 1)"
        }
        return group.title
    }
}

#Preview("Empty Group") {
    @Previewable @FocusState var focusedField: PuzzleCreationView.FocusField?
    
    let words = (0...3).map { PuzzleWord(text: "", position: $0) }
    let group = PuzzleGroup(title: "", position: 0, words: words)
    
    CategoryRowView(
        group: group,
        focusedField: $focusedField
    )
    .padding()
}

#Preview("Filled Group") {
    @Previewable @FocusState var focusedField: PuzzleCreationView.FocusField?
    
    let words = [
        PuzzleWord(text: "LATTE", position: 0),
        PuzzleWord(text: "MOCHA", position: 1),
        PuzzleWord(text: "ESPRESSO", position: 2),
        PuzzleWord(text: "CAPPUCCINO", position: 3)
    ]
    let group = PuzzleGroup(title: "Coffee Drinks", position: 0, words: words)
    
    CategoryRowView(
        group: group,
        focusedField: $focusedField
    )
    .padding()
}

#Preview("Mixed Content") {
    @Previewable @FocusState var focusedField: PuzzleCreationView.FocusField?
    
    let words = [
        PuzzleWord(text: "PYTHON", position: 0),
        PuzzleWord(text: "SWIFT", position: 1),
        PuzzleWord(text: "", position: 2),
        PuzzleWord(text: "", position: 3)
    ]
    let group = PuzzleGroup(title: "Programming Languages", position: 1, words: words)
    
    CategoryRowView(
        group: group,
        focusedField: $focusedField
    )
    .padding()
}

