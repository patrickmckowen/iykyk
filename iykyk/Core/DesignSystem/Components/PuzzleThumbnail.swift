//
//  PuzzleThumbnail.swift
//  iykyk
//
//  A 1x4 mini-grid icon that visualizes puzzle state and group completion as horizontal rows.
//

import SwiftUI

struct PuzzleThumbnail: View {
    let isPublished: Bool
    /// Set of group positions (0-3) that are complete (all 4 words filled or solved)
    var completedGroups: Set<Int> = []
    var size: CGFloat = 32
    
    private let spacing: CGFloat = 2
    
    /// Height of each row: (totalHeight - 3 gaps) / 4 rows
    private var rowHeight: CGFloat {
        (size - 3 * spacing) / 4
    }
    
    /// Width equals total height to make the thumbnail square
    private var totalWidth: CGFloat {
        size
    }
    
    var body: some View {
        VStack(spacing: spacing) {
            rowView(position: 0)
            rowView(position: 1)
            rowView(position: 2)
            rowView(position: 3)
        }
        .frame(width: totalWidth, height: size)
    }
    
    @ViewBuilder
    private func rowView(position: Int) -> some View {
        let color = GroupColors.color(for: position)
        let isFilled = isPublished || completedGroups.contains(position)
        
        RoundedRectangle(cornerRadius: 2)
            .fill(isFilled ? color : Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .strokeBorder(
                        isFilled ? color : Color.secondary.opacity(0.5),
                        lineWidth: isFilled ? 0 : 1
                    )
            )
            .frame(width: totalWidth, height: rowHeight)
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
            PuzzleThumbnail(isPublished: false, completedGroups: [0, 1])
            Text("2 groups")
                .font(.caption)
        }
        VStack {
            PuzzleThumbnail(isPublished: false, completedGroups: [0, 1, 2])
            Text("3 groups")
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
