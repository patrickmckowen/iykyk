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
        VStack(alignment: .leading, spacing: 8) {
            // Group name TextField with difficulty label
            HStack {
                TextField("Group name", text: $group.title)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 4)
                    .focused($focusedField, equals: .groupName(groupIndex: group.position))
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isGroupNameFocused)
                    .submitLabel(.done)
                    .onSubmit {
                        focusedField = nil
                    }
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.words)
                
                Text(GroupDifficulty.label(for: group.position).uppercased())
                    .font(.caption2)
                    .foregroundStyle(difficultyColor)
                    .fontWeight(.bold)
            }
            
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
        }
        .padding(12)
        .background {
            ZStack {
                // Glass material base
                Rectangle()
                    .fill(.ultraThinMaterial)
                
                // Colored gradient layer
                LinearGradient(
                    colors: [
                        difficultyColor.opacity(0.15),
                        difficultyColor.opacity(0.05),
                        .clear
                    ],
                    startPoint: .topTrailing,
                    endPoint: .bottomLeading
                )
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            .white.opacity(0.5),
                            .white.opacity(0.1)
                        ],
                        startPoint: .topTrailing,
                        endPoint: .bottomLeading
                    ),
                    lineWidth: 1
                )
        )
        .shadow(
            color: difficultyColor.opacity(0.1),
            radius: 8,
            x: 0,
            y: 4
        )
        .enableInjection()
    }
}

/// Wrapper view that uses @Bindable to efficiently bind to PuzzleWord.text
private struct WordTileWrapper: View {
    @Bindable var word: PuzzleWord
    @FocusState.Binding var focusedField: PuzzleCreationFocusField?
    let groupPosition: Int
    
    var body: some View {
        EditableWordTile(
            text: $word.text,
            focusedField: $focusedField,
            fieldID: .word(groupIndex: groupPosition, wordIndex: word.position)
        )
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

