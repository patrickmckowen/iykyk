//
//  GameTileButton.swift
//  iykyk
//
//  Shared component for interactive puzzle tiles during gameplay.
//

import SwiftUI

/// A tappable tile button used during puzzle gameplay.
/// Displays word text with selection state and optional shake effect.
struct GameTileButton: View {
    let text: String
    let isSelected: Bool
    let isShaking: Bool
    let shakeAmount: CGFloat
    let isDisabled: Bool
    let onTap: () -> Void
    
    // Animation state
    var isLifted: Bool = false
    
    /// When non-nil, displays the tile as solved with the group's difficulty color (0-3)
    var groupDifficultyPosition: Int? = nil
    
    private var backgroundColor: Color {
        if let position = groupDifficultyPosition {
            return GroupColors.color(for: position)
        }
        return isSelected ? Color(.systemGray4) : Color(.systemGray6)
    }
    
    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                onTap()
            }
        } label: {
            GeometryReader { geometry in
                AutoSizingTileText(text: text, containerSize: geometry.size)
                    .foregroundStyle(Color.primary)
                    .background(backgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
        .buttonStyle(.plain)
        .aspectRatio(1, contentMode: .fit)
        .offset(y: isLifted ? -12 : 0)
        .modifier(ShakeEffect(amount: isShaking ? shakeAmount : 0))
        .disabled(isDisabled)
    }
}

#Preview {
    VStack(spacing: 16) {
        HStack(spacing: 8) {
            GameTileButton(
                text: "WORD",
                isSelected: false,
                isShaking: false,
                shakeAmount: 0,
                isDisabled: false,
                onTap: {}
            )
            
            GameTileButton(
                text: "SELECTED",
                isSelected: true,
                isShaking: false,
                shakeAmount: 0,
                isDisabled: false,
                onTap: {}
            )
        }
        
        HStack(spacing: 8) {
            GameTileButton(
                text: "LIFTED",
                isSelected: true,
                isShaking: false,
                shakeAmount: 0,
                isDisabled: false,
                onTap: {},
                isLifted: true
            )
            
            GameTileButton(
                text: "SOLVED",
                isSelected: false,
                isShaking: false,
                shakeAmount: 0,
                isDisabled: true,
                onTap: {},
                groupDifficultyPosition: 0
            )
        }
        
        // Show all difficulty colors
        HStack(spacing: 8) {
            ForEach(0..<4, id: \.self) { position in
                GameTileButton(
                    text: "D\(position)",
                    isSelected: false,
                    isShaking: false,
                    shakeAmount: 0,
                    isDisabled: true,
                    onTap: {},
                    groupDifficultyPosition: position
                )
            }
        }
    }
    .padding()
}

