//
//  EditableWordTile.swift
//  iykyk
//
//  Created by Patrick McKowen on 11/19/25.
//

import SwiftUI
import UIKit
import Inject

struct EditableWordTile: View {
    @Binding var text: String
    @FocusState.Binding var focusedField: PuzzleCreationFocusField?
    let fieldID: PuzzleCreationFocusField
    
    @State private var fontSize: CGFloat = 16
    @State private var fontSizeTask: Task<Void, Never>?
    @State private var currentSize: CGSize = .zero
    @ObserveInjection private var inject
    
    // Visual constants
    private let minFontSize: CGFloat = 10
    private let maxFontSize: CGFloat = 14
    private let tilePadding: CGFloat = 4
    private let textHorizontalBuffer: CGFloat = 10
    private let cornerRadius: CGFloat = 16
    
    private var activeBorderColor: Color {
        if case .word(let groupIndex, _) = fieldID {
            return GroupColors.color(for: groupIndex)
        }
        return .gray
    }
    
    /// Whether this tile is currently focused
    private var isFocused: Bool {
        focusedField == fieldID
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                TextField("WORD", text: $text, axis: .vertical)
                    .lineLimit(2)
                    .textFieldStyle(.plain)
                    .font(.system(size: fontSize, weight: .bold))
                    .foregroundStyle(.primary)
                    .saturation(text.isEmpty ? 1.3 : 1.0)
                    .multilineTextAlignment(.center)
                    .padding(tilePadding)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .background(.thickMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .strokeBorder(.white.opacity(0.6),
                                lineWidth: 2
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
                        // If user added a newline (pressed done/return), dismiss keyboard
                        if newValue.contains("\n") {
                            text = newValue.replacingOccurrences(of: "\n", with: "")
                            focusedField = nil
                        }
                        // Debounce font size calculation during typing
                        fontSizeTask?.cancel()
                        fontSizeTask = Task {
                            try? await Task.sleep(for: .milliseconds(100))
                            guard !Task.isCancelled else { return }
                            await MainActor.run {
                                updateFontSize(availableSize: currentSize)
                            }
                        }
                    }
                    .onChange(of: geometry.size) { _, newSize in
                        // Only recalculate if size changed significantly (ignore scroll animation micro-changes)
                        let widthDiff = abs(newSize.width - currentSize.width)
                        let heightDiff = abs(newSize.height - currentSize.height)
                        guard widthDiff > 1 || heightDiff > 1 else { return }
                        
                        currentSize = newSize
                        updateFontSize(availableSize: newSize)
                    }
                    .onAppear {
                        currentSize = geometry.size
                        updateFontSize(availableSize: geometry.size)
                    }
                    .contentShape(RoundedRectangle(cornerRadius: cornerRadius))
                    .simultaneousGesture(
                        TapGesture()
                            .onEnded {
                                focusedField = fieldID
                            }
                    )
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .enableInjection()
    }
    
    private func updateFontSize(availableSize: CGSize) {
        let width = availableSize.width - (tilePadding * 2) - textHorizontalBuffer
        let height = availableSize.height - (tilePadding * 2)
        
        guard width > 0 && height > 0 else { return }
        
        if text.isEmpty {
            fontSize = 14 // Default size for placeholder
            return
        }
        
        if text.containsOnlyEmoji {
            fontSize = 22
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

private struct EditableWordTile_PreviewWrapper: View {
    @State private var text = "SPELLING BEE"
    @FocusState private var focusedField: PuzzleCreationFocusField?
    
    var body: some View {
        EditableWordTile(
            text: $text,
            focusedField: $focusedField,
            fieldID: .word(groupIndex: 0, wordIndex: 0)
        )
        .frame(width: 100)
        .padding()
    }
}

#Preview {
    EditableWordTile_PreviewWrapper()
}

