//
//  RootView.swift
//  iykyk
//
//  Created by Patrick McKowen on 11/18/25.
//

import SwiftUI

struct RootView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("iykyk")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Foundation Ready")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                
                Text("✓ Domain Models")
                Text("✓ Persistence Layer")
                Text("✓ Repository Pattern")
                Text("✓ Validation & Fixtures")
                
                Divider()
                    .padding(.vertical)
                
                NavigationLink {
                    PuzzleCreationView()
                } label: {
                    Label("Create Puzzle", systemImage: "plus.square")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
            }
            .padding()
        }
    }
}

#Preview {
    RootView()
}

