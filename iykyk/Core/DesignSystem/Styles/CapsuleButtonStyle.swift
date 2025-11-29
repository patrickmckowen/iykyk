//
//  CapsuleButtonStyle.swift
//  iykyk
//
//  Shared button style for game controls.
//

import SwiftUI

/// A capsule-shaped button style used for game controls (Shuffle, Deselect All, Submit).
struct CapsuleButtonStyle: ButtonStyle {
    var isFilled: Bool = false
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.colorScheme) private var colorScheme
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .padding(.vertical, 14)
            .padding(.horizontal, 20)
            .foregroundStyle(textColor)
            .background(
                Capsule()
                    .fill(backgroundColor)
            )
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
    
    private var textColor: Color {
        if isFilled {
            return colorScheme == .dark ? .black : .white
        }
        return isEnabled ? .primary : .secondary
    }
    
    private var backgroundColor: Color {
        if isFilled {
            return .primary
        }
        return isEnabled ? Color(.systemGray6) : Color(.systemGray6)
    }
}

#Preview {
    VStack(spacing: 16) {
        Button("Shuffle") {}
            .buttonStyle(CapsuleButtonStyle())
        
        Button("Submit") {}
            .buttonStyle(CapsuleButtonStyle(isFilled: true))
        
        Button("Disabled") {}
            .buttonStyle(CapsuleButtonStyle())
            .disabled(true)
    }
    .padding()
}

