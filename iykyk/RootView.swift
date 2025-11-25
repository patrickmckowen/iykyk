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
    @State private var showPublishToast = false
    @State private var publishedPuzzleTitle = ""
    @State private var createNavigationPath = NavigationPath()
    
    var body: some View {
        ZStack {
            TabView {
                Tab("Create", systemImage: "scribble.variable") {
                    NavigationStack(path: $createNavigationPath) {
                        PuzzleLibraryView(mode: .create)
                            .navigationDestination(for: Puzzle.self) { puzzle in
                                if puzzle.isPublished {
                                    PuzzlePreviewView(puzzle: puzzle)
                                } else {
                                    PuzzleCreationView(puzzle: puzzle)
                                }
                            }
                            .navigationDestination(for: String.self) { value in
                                if value == "create" {
                                    PuzzleCreationView()
                                }
                            }
                    }
                }
                
                Tab("Play", systemImage: "xmark.triangle.circle.square") {
                    NavigationStack {
                        PuzzleLibraryView(mode: .play)
                            .navigationDestination(for: Puzzle.self) { puzzle in
                                PuzzlePlayView(puzzle: puzzle)
                            }
                    }
                }
            }
            
            // Success toast overlay
            if showPublishToast {
                VStack {
                    Spacer()
                    
                    PublishSuccessToast(title: publishedPuzzleTitle)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.bottom, 100)
                }
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showPublishToast)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .puzzlePublished)) { notification in
            if let title = notification.userInfo?["puzzleTitle"] as? String {
                publishedPuzzleTitle = title
            }
            
            // Pop navigation stack to root
            createNavigationPath = NavigationPath()
            
            // Show toast
            withAnimation {
                showPublishToast = true
            }
            
            // Hide toast after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation {
                    showPublishToast = false
                }
            }
        }
        .enableInjection()
    }
}

// MARK: - Publish Success Toast

private struct PublishSuccessToast: View {
    let title: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.title2)
                .foregroundStyle(.green)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Published!")
                    .font(.subheadline.bold())
                
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(.regularMaterial, in: Capsule())
        .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
    }
}

#Preview {
    RootView()
        .modelContainer(try! PreviewSampleData.seededContainer())
}
