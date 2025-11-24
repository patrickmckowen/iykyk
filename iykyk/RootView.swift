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
    @State private var selectedMode: LibraryMode = .create
    @ObserveInjection private var inject
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // Switch between library modes based on selection
                Group {
                    switch selectedMode {
                    case .create:
                        PuzzleLibraryView(mode: .create)
                    case .play:
                        PuzzleLibraryView(mode: .play)
                    }
                }
                .safeAreaPadding(.bottom, 80) // Make room for the tab bar
                
                // Liquid Glass Tab Bar
                GlassTabBar(selectedMode: $selectedMode)
                    .padding(.bottom, 20)
            }
            .navigationDestination(for: Puzzle.self) { puzzle in
                if selectedMode == .create {
                    PuzzleCreationView(puzzle: puzzle)
                } else {
                    PuzzlePlayView(puzzle: puzzle)
                }
            }
            .navigationDestination(for: String.self) { value in
                if value == "create" {
                    PuzzleCreationView()
                }
            }
        }
        .enableInjection()
    }
}

struct GlassTabBar: View {
    @Binding var selectedMode: LibraryMode
    @Namespace private var animation
    
    var body: some View {
        HStack(spacing: 0) {
            tabButton(mode: .create, icon: "square.grid.2x2", title: "Create")
            tabButton(mode: .play, icon: "play.fill", title: "Play")
        }
        .padding(6)
        .background(.regularMaterial)
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        .overlay(
            Capsule()
                .strokeBorder(.white.opacity(0.2), lineWidth: 1)
        )
    }
    
    @ViewBuilder
    private func tabButton(mode: LibraryMode, icon: String, title: String) -> some View {
        let isSelected = selectedMode == mode
        
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedMode = mode
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                
                if isSelected {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                        .transition(.move(edge: .leading).combined(with: .opacity))
                        .lineLimit(1)
                        .fixedSize()
                }
            }
            .foregroundStyle(isSelected ? .primary : .secondary)
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .background {
                if isSelected {
                    Capsule()
                        .fill(Color.accentColor.opacity(0.15))
                        .matchedGeometryEffect(id: "activeTab", in: animation)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    RootView()
        .modelContainer(for: Puzzle.self, inMemory: true)
}
