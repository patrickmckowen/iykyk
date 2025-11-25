//
//  MistakesRemainingView.swift
//  iykyk
//
//  Shared component for displaying remaining guesses.
//

import SwiftUI

/// Displays the number of remaining incorrect guesses as filled/unfilled dots.
struct MistakesRemainingView: View {
    let remaining: Int
    let total: Int
    
    init(remaining: Int, total: Int = 4) {
        self.remaining = remaining
        self.total = total
    }
    
    var body: some View {
        HStack(spacing: 8) {
            Text("Mistakes Remaining:")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            HStack(spacing: 6) {
                ForEach(0..<total, id: \.self) { index in
                    Circle()
                        .fill(index < remaining ? Color.primary.opacity(0.6) : Color.secondary.opacity(0.2))
                        .frame(width: 12, height: 12)
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        MistakesRemainingView(remaining: 4)
        MistakesRemainingView(remaining: 3)
        MistakesRemainingView(remaining: 2)
        MistakesRemainingView(remaining: 1)
        MistakesRemainingView(remaining: 0)
    }
    .padding()
}

