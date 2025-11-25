//
//  EmptyStateView.swift
//  iykyk
//
//  Empty state placeholder for the puzzle library.
//

import SwiftUI

struct EmptyStateView: View {
    var mode: LibraryMode = .create
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "square.grid.4x4")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text(mode == .create ? "No Puzzles Yet" : "No Published Puzzles")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(mode == .create ? "Tap the + button in the toolbar to create your first puzzle" : "Publish a puzzle from Create mode to play it here")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    VStack {
        EmptyStateView(mode: .create)
        Divider()
        EmptyStateView(mode: .play)
    }
}

