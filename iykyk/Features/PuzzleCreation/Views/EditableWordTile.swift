//
//  EditableWordTile.swift
//  iykyk
//
//  Created by Patrick McKowen on 11/19/25.
//

import SwiftUI
import UIKit

struct EditableWordTile: View {
    @Binding var text: String
    @FocusState.Binding var focusedField: PuzzleCreationView.FocusField?
    let fieldID: PuzzleCreationView.FocusField
    
    @State private var fontSize: CGFloat = 16
    
    // Visual constants
    private let minFontSize: CGFloat = 10
    private let maxFontSize: CGFloat = 14
    private let tilePadding: CGFloat = 4
    private let cornerRadius: CGFloat = 8
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                TextField("WORD", text: $text, axis: .vertical)
                    .textFieldStyle(.plain)
                    .font(.system(size: fontSize, weight: .bold))
                    .multilineTextAlignment(.center)
                    .padding(tilePadding)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .background(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .strokeBorder(
                                focusedField == fieldID ? Color.accentColor : Color(.systemGray4),
                                lineWidth: focusedField == fieldID ? 2 : 1
                            )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                    .focused($focusedField, equals: fieldID)
                    .submitLabel(.done)
                    .onSubmit {
                        focusedField = nil
                    }
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.characters)
                    .onChange(of: text) { oldValue, newValue in
                        // Strip explicit newlines to prevent forcing >2 lines
                        let sanitized = newValue.replacingOccurrences(of: "\n", with: " ")
                        if sanitized != newValue {
                            text = sanitized
                        }
                        updateFontSize(availableSize: geometry.size)
                    }
                    .onChange(of: geometry.size) { _, newSize in
                        updateFontSize(availableSize: newSize)
                    }
                    .onAppear {
                        updateFontSize(availableSize: geometry.size)
                    }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
    
    private func updateFontSize(availableSize: CGSize) {
        let width = availableSize.width - (tilePadding * 2)
        let height = availableSize.height - (tilePadding * 2)
        
        guard width > 0 && height > 0 else { return }
        
        if text.isEmpty {
            fontSize = 14 // Default size for placeholder
            return
        }
        
        // Find best fit
        for size in stride(from: maxFontSize, through: minFontSize, by: -1) {
            let font = UIFont.systemFont(ofSize: size, weight: .bold)
            
            // 1. Check if any single word exceeds width
            let words = text.split(separator: " ")
            let maxWordWidth = words.map { word -> CGFloat in
                let attrString = NSAttributedString(string: String(word), attributes: [.font: font])
                return attrString.size().width
            }.max() ?? 0
            
            if maxWordWidth > width {
                continue
            }
            
            // 2. Check total bounds
            let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
            let attrString = NSAttributedString(string: text, attributes: [.font: font])
            let boundingBox = attrString.boundingRect(with: constraintRect,
                                                    options: .usesLineFragmentOrigin,
                                                    context: nil)
            
            if boundingBox.height <= height {
                fontSize = size
                return
            }
        }
        
        fontSize = minFontSize
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
    .frame(width: 100)
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
    .frame(width: 100)
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
    .frame(width: 100)
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
    .frame(width: 100)
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
    .frame(width: 100)
    .padding()
}
