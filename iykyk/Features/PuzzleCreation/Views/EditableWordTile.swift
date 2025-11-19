//
//  EditableWordTile.swift
//  iykyk
//
//  Created by Patrick McKowen on 11/19/25.
//

import SwiftUI

struct EditableWordTile: View {
    @Binding var text: String
    @FocusState.Binding var focusedField: PuzzleCreationView.FocusField?
    let fieldID: PuzzleCreationView.FocusField
    
    @State private var fontSize: CGFloat = 14
    @State private var measuredSize: CGSize = .zero
    
    // Visual constants
    private let minFontSize: CGFloat = 12
    private let maxFontSize: CGFloat = 14
    private let tileHeight: CGFloat = 52
    private let tilePadding: CGFloat = 8
    private let cornerRadius: CGFloat = 8
    
    var body: some View {
        ZStack {
            // Hidden text for measurement
            Text(text.isEmpty ? "WORD" : text)
                .font(.system(size: fontSize, weight: .medium))
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .background(
                    GeometryReader { geometry in
                        Color.clear.preference(
                            key: TextSizePreferenceKey.self,
                            value: geometry.size
                        )
                    }
                )
                .hidden()
            
            // Visible TextField
            TextField("WORD", text: $text, axis: .vertical)
                .textFieldStyle(.plain)
                .font(.system(size: fontSize, weight: .medium))
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, maxHeight: tileHeight)
                .padding(.horizontal, tilePadding)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(Color(.systemBackground))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .strokeBorder(
                            focusedField == fieldID ? Color.accentColor : Color(.systemGray4),
                            lineWidth: focusedField == fieldID ? 2 : 1
                        )
                )
                .focused($focusedField, equals: fieldID)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.characters)
        }
        .frame(height: tileHeight)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .onPreferenceChange(TextSizePreferenceKey.self) { size in
            measuredSize = size
            adjustFontSize()
        }
        .onChange(of: text) { oldValue, newValue in
            // Strip explicit newlines to prevent forcing >2 lines
            let sanitized = newValue.replacingOccurrences(of: "\n", with: " ")
            if sanitized != newValue {
                text = sanitized
            }
        }
        .animation(.easeInOut(duration: 0.2), value: fontSize)
    }
    
    private func adjustFontSize() {
        let availableWidth = UIScreen.main.bounds.width / 4 - tilePadding * 3 // rough estimate
        let availableHeight = tileHeight - 12
        
        // If text is empty, reset to max
        guard !text.isEmpty else {
            fontSize = maxFontSize
            return
        }
        
        // Check if text exceeds bounds
        let exceedsWidth = measuredSize.width > availableWidth - tilePadding * 2
        let exceedsHeight = measuredSize.height > availableHeight
        
        if exceedsWidth || exceedsHeight {
            // Shrink font toward minimum
            let newSize = max(minFontSize, fontSize - 0.5)
            if newSize != fontSize {
                fontSize = newSize
            }
        } else if measuredSize.width < availableWidth * 0.7 && measuredSize.height < availableHeight * 0.7 {
            // Text fits comfortably, try to grow back toward maximum
            let newSize = min(maxFontSize, fontSize + 0.5)
            if newSize != fontSize {
                fontSize = newSize
            }
        }
    }
}

#Preview("Empty Tile") {
    @Previewable @State var text = ""
    @Previewable @FocusState var focusedField: PuzzleCreationView.FocusField?
    
    EditableWordTile(
        text: $text,
        focusedField: $focusedField,
        fieldID: .word(groupIndex: 0, wordIndex: 0)
    )
    .padding()
}

#Preview("Short Word") {
    @Previewable @State var text = "GO"
    @Previewable @FocusState var focusedField: PuzzleCreationView.FocusField?
    
    EditableWordTile(
        text: $text,
        focusedField: $focusedField,
        fieldID: .word(groupIndex: 0, wordIndex: 0)
    )
    .padding()
}

#Preview("Long Single Word") {
    @Previewable @State var text = "CAPPUCCINO"
    @Previewable @FocusState var focusedField: PuzzleCreationView.FocusField?
    
    EditableWordTile(
        text: $text,
        focusedField: $focusedField,
        fieldID: .word(groupIndex: 0, wordIndex: 0)
    )
    .padding()
}

#Preview("Multi-word Phrase") {
    @Previewable @State var text = "SPELLING BEE"
    @Previewable @FocusState var focusedField: PuzzleCreationView.FocusField?
    
    EditableWordTile(
        text: $text,
        focusedField: $focusedField,
        fieldID: .word(groupIndex: 0, wordIndex: 0)
    )
    .padding()
}

#Preview("Very Long Phrase") {
    @Previewable @State var text = "REALLY LONG PHRASE THAT SHOULD SHRINK"
    @Previewable @FocusState var focusedField: PuzzleCreationView.FocusField?
    
    EditableWordTile(
        text: $text,
        focusedField: $focusedField,
        fieldID: .word(groupIndex: 0, wordIndex: 0)
    )
    .padding()
}

