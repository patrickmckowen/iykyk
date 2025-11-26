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
    let namespace: Namespace.ID
    let tileID: UUID
    let onTap: () -> Void
    
    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                onTap()
            }
        } label: {
            GeometryReader { geometry in
                AutoSizingTileText(text: text, containerSize: geometry.size)
                    .foregroundStyle(Color.primary)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(isSelected ? Color(.systemGray4) : Color(.systemGray6))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .strokeBorder(Color(.systemGray4), lineWidth: 1)
                            )
                    )
                    .matchedGeometryEffect(id: tileID, in: namespace, isSource: false)
            }
        }
        .buttonStyle(.plain)
        .frame(height: 80)
        .modifier(ShakeEffect(amount: isShaking ? shakeAmount : 0))
        .disabled(isDisabled)
    }
}

#Preview {
    @Previewable @Namespace var namespace
    
    VStack(spacing: 16) {
        HStack(spacing: 8) {
            GameTileButton(
                text: "WORD",
                isSelected: false,
                isShaking: false,
                shakeAmount: 0,
                isDisabled: false,
                namespace: namespace,
                tileID: UUID(),
                onTap: {}
            )
            
            GameTileButton(
                text: "SELECTED",
                isSelected: true,
                isShaking: false,
                shakeAmount: 0,
                isDisabled: false,
                namespace: namespace,
                tileID: UUID(),
                onTap: {}
            )
        }
    }
    .padding()
}

