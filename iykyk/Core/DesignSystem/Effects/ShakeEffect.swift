//
//  ShakeEffect.swift
//  iykyk
//
//  Shared shake animation effect for incorrect guesses.
//

import SwiftUI

/// A geometry effect that creates a horizontal shake animation.
/// Used to indicate incorrect guesses in puzzle gameplay.
struct ShakeEffect: GeometryEffect {
    var amount: CGFloat
    
    var animatableData: CGFloat {
        get { amount }
        set { amount = newValue }
    }
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        let translation = sin(amount * .pi * 2) * 10
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}

#Preview {
    struct ShakePreview: View {
        @State private var shakeAmount: CGFloat = 0
        
        var body: some View {
            VStack(spacing: 20) {
                Text("WORD")
                    .font(.headline)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .modifier(ShakeEffect(amount: shakeAmount))
                
                Button("Shake") {
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                        shakeAmount = 2.0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        shakeAmount = 0
                    }
                }
            }
            .padding()
        }
    }
    
    return ShakePreview()
}

