//
//  AutoSizingTileText.swift
//  iykyk
//
//  Shared component for auto-sizing text within puzzle tiles.
//

import SwiftUI
import UIKit

/// A text view that automatically sizes its font to fit within a container.
/// Used by both editable tiles (creation) and display tiles (play/preview).
struct AutoSizingTileText: View {
    let text: String
    let containerSize: CGSize
    
    @State private var fontSize: CGFloat = 16
    
    // Visual constants
    private let minFontSize: CGFloat = 10
    private let maxFontSize: CGFloat = 14
    private let tilePadding: CGFloat = 4
    private let textHorizontalBuffer: CGFloat = 10
    
    var body: some View {
        Text(text)
            .font(.system(size: fontSize, weight: .bold))
            .multilineTextAlignment(.center)
            .padding(tilePadding)
            .frame(width: containerSize.width, height: containerSize.height)
            .onChange(of: containerSize) { _, newSize in
                updateFontSize(availableSize: newSize)
            }
            .onChange(of: text) { _, _ in
                updateFontSize(availableSize: containerSize)
            }
            .onAppear {
                updateFontSize(availableSize: containerSize)
            }
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

#Preview {
    VStack(spacing: 20) {
        GeometryReader { geometry in
            AutoSizingTileText(text: "WORD", containerSize: geometry.size)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .frame(width: 80, height: 80)
        
        GeometryReader { geometry in
            AutoSizingTileText(text: "LONGER TEXT", containerSize: geometry.size)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .frame(width: 80, height: 80)
    }
    .padding()
}

