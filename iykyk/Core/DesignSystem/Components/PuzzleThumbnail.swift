//
//  PuzzleThumbnail.swift
//  iykyk
//
//  A 2x2 mini-grid icon that visualizes puzzle state and group completion.
//

import SwiftUI

struct PuzzleThumbnail: View {
    let isPublished: Bool
    /// Set of group positions (0-3) that are complete (all 4 words filled)
    var completedGroups: Set<Int> = []
    var size: CGFloat = 32
    
    private let spacing: CGFloat = 2
    
    private var squareSize: CGFloat {
        (size - spacing) / 2
    }
    
    var body: some View {
        VStack(spacing: spacing) {
            HStack(spacing: spacing) {
                squareView(position: 0)
                squareView(position: 1)
            }
            HStack(spacing: spacing) {
                squareView(position: 2)
                squareView(position: 3)
            }
        }
        .frame(width: size, height: size)
    }
    
    @ViewBuilder
    private func squareView(position: Int) -> some View {
        let color = GroupColors.color(for: position)
        let isFilled = isPublished || completedGroups.contains(position)
        
        RoundedRectangle(cornerRadius: 3)
            .fill(isFilled ? color : Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 3)
                    .strokeBorder(
                        isFilled ? color : Color.secondary.opacity(0.5),
                        lineWidth: isFilled ? 0 : 1.5
                    )
            )
            .frame(width: squareSize, height: squareSize)
    }
}

#Preview {
    HStack(spacing: 24) {
        VStack {
            PuzzleThumbnail(isPublished: false, completedGroups: [])
            Text("Empty")
                .font(.caption)
        }
        VStack {
            PuzzleThumbnail(isPublished: false, completedGroups: [0])
            Text("1 group")
                .font(.caption)
        }
        VStack {
            PuzzleThumbnail(isPublished: false, completedGroups: [0, 2])
            Text("2 groups")
                .font(.caption)
        }
        VStack {
            PuzzleThumbnail(isPublished: true, completedGroups: [])
            Text("Published")
                .font(.caption)
        }
    }
    .padding()
}
