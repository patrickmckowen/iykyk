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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Group name TextField with difficulty label
            HStack {
                TextField("Group name", text: $group.title)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 4)
                    .focused($focusedField, equals: .groupName(groupIndex: group.position))
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isGroupNameFocused)
                    .submitLabel(.done)
                    .onSubmit {
                        focusedField = nil
                    }
                
                Text(GroupDifficulty.label(for: group.position).uppercased())
                    .font(.caption2)
                    .foregroundStyle(GroupDifficulty.color(for: group.position))
                    .fontWeight(.medium)
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
        .enableInjection()
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
