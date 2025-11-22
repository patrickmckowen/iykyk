//
//  RootView.swift
//  iykyk
//
//  Created by Patrick McKowen on 11/18/25.
//

import SwiftUI
import SwiftData

struct RootView: View {
    var body: some View {
        PuzzleLibraryView()
    }
}

#Preview {
    RootView()
        .modelContainer(for: Puzzle.self, inMemory: true)
}

