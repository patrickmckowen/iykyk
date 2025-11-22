//
//  RootView.swift
//  iykyk
//
//  Created by Patrick McKowen on 11/18/25.
//

import SwiftUI
import SwiftData
import Inject

struct RootView: View {
    @ObserveInjection private var inject
    
    var body: some View {
        PuzzleLibraryView()
            .enableInjection()
    }
}

#Preview {
    RootView()
        .modelContainer(for: Puzzle.self, inMemory: true)
}

