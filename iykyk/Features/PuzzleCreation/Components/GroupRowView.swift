//
//  GroupRowView.swift
//  iykyk
//
//  Created by Patrick McKowen on 11/19/25.
//

import SwiftUI
import Inject

struct GroupRowView: View {
    @Bindable var group: PuzzleGroup
    @FocusState.Binding var focusedField: PuzzleCreationFocusField?
    @ObserveInjection private var inject
    
    private var isGroupNameFocused: Bool {
        if case .groupName(let index) = focusedField {
            return index == group.position
        }
        return false
    }
    
    /// The difficulty color for this group's position
    private var difficultyColor: Color {
        GroupDifficulty.color(for: group.position)
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            // Group name TextField
            TextField("Group name", text: $group.title)
                .font(.headline)
                .foregroundStyle(.primary)
                .saturation(group.title.isEmpty ? 1.3 : 1.0)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 4)
                .padding(.vertical, 16)
                .focused($focusedField, equals: .groupName(groupIndex: group.position))
                .submitLabel(.done)
                .onSubmit {
                    focusedField = nil
                }
                .autocorrectionDisabled()
                .id(PuzzleCreationFocusField.groupName(groupIndex: group.position))
                .frame(maxWidth: .infinity)
            
            // 4 word tiles in a row
            HStack(spacing: 4) {
                ForEach(group.words.sorted(by: { $0.position < $1.position })) { word in
                    WordTileWrapper(
                        word: word,
                        focusedField: $focusedField,
                        groupPosition: group.position
                    )
                }
            }
            .padding(.bottom, 12)
        }
        .padding(.horizontal, 12)
        .background(difficultyColor.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .enableInjection()
    }
}

/// Wrapper view that uses @Bindable to efficiently bind to PuzzleWord.text
private struct WordTileWrapper: View {
    @Bindable var word: PuzzleWord
    @FocusState.Binding var focusedField: PuzzleCreationFocusField?
    let groupPosition: Int
    
    var body: some View {
        let fieldID: PuzzleCreationFocusField = .word(groupIndex: groupPosition, wordIndex: word.position)
        
        return EditableWordTile(
            text: $word.text,
            focusedField: $focusedField,
            fieldID: fieldID
        )
        .id(fieldID)
    }
}

private struct GroupRowView_PreviewWrapper: View {
    @FocusState private var focusedField: PuzzleCreationFocusField?
    
    private let group: PuzzleGroup = {
        let words = [
            PuzzleWord(text: "LATTE", position: 0),
            PuzzleWord(text: "MOCHA", position: 1),
            PuzzleWord(text: "ESPRESSO", position: 2),
            PuzzleWord(text: "CAPPUCCINO", position: 3)
        ]
        return PuzzleGroup(title: "Coffee Drinks", position: 0, words: words)
    }()
    
    var body: some View {
        GroupRowView(
            group: group,
            focusedField: $focusedField
        )
        .padding()
    }
}

#Preview {
    GroupRowView_PreviewWrapper()
}

