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
    
    // Animation state
    var isLifted: Bool = false
    var morphColor: Color? = nil
    
    private var backgroundColor: Color {
        if let morphColor {
            return morphColor
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
                    .matchedGeometryEffect(id: tileID, in: namespace, isSource: false)
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
        
        HStack(spacing: 8) {
            GameTileButton(
                text: "LIFTED",
                isSelected: true,
                isShaking: false,
                shakeAmount: 0,
                isDisabled: false,
                namespace: namespace,
                tileID: UUID(),
                onTap: {},
                isLifted: true
            )
            
            GameTileButton(
                text: "MORPH",
                isSelected: true,
                isShaking: false,
                shakeAmount: 0,
                isDisabled: false,
                namespace: namespace,
                tileID: UUID(),
                onTap: {},
                isLifted: true,
                morphColor: GroupColors.color(for: 0)
            )
        }
    }
    .padding()
}

