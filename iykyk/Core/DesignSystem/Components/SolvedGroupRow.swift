//
//  SolvedGroupRow.swift
//  iykyk
//
//  Shared component for displaying a solved puzzle group.
//

import SwiftUI

/// Displays a solved group with its title and words in the group's color.
/// Used in both PuzzlePreviewView and PuzzlePlayView.
struct SolvedGroupRow: View {
    let title: String
    let words: [String]
    let position: Int
    var showText: Bool = true
    var showBackground: Bool = true
    
    private var wordsList: String {
        words.joined(separator: ", ")
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Text(title.uppercased())
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
            
            Text(wordsList)
                .font(.system(size: 14))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
                .padding(.horizontal, 4)
        }
        .opacity(showText ? 1 : 0)
        .frame(maxWidth: .infinity)
        .frame(minHeight: 80) // Allow expansion for tiles during morph
        .background(showBackground ? GroupColors.color(for: position) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    VStack(spacing: 8) {
        SolvedGroupRow(
            title: "Coffee Drinks",
            words: ["LATTE", "MOCHA", "ESPRESSO", "CAPPUCCINO"],
            position: 0
        )
        
        SolvedGroupRow(
            title: "Colors",
            words: ["RED", "BLUE", "GREEN", "YELLOW"],
            position: 1
        )
        
        SolvedGroupRow(
            title: "Animals",
            words: ["DOG", "CAT", "BIRD", "FISH"],
            position: 2
        )
        
        SolvedGroupRow(
            title: "Numbers",
            words: ["ONE", "TWO", "THREE", "FOUR"],
            position: 3
        )
    }
    .padding()
}

