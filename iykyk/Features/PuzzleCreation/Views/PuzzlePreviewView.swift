//
//  PuzzlePreviewView.swift
//  iykyk
//
//  Created by AI on 11/22/25.
//

import SwiftUI
import SwiftData
import Inject

struct PuzzlePreviewView: View {
    @Bindable var puzzle: Puzzle
    
    @State private var shuffledWords: [PuzzleWord] = []
    @State private var validationIssues: [ValidationIssue] = []
    @State private var tilesVisible: Bool = false
    
    @Namespace private var tileNamespace
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @ObserveInjection private var inject
    
    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 8), count: 4)
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // Title for published puzzles
            if puzzle.isPublished, let number = puzzle.sequenceNumber {
                Text("Puzzle #\(number)")
                    .font(.title.bold())
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)
            }
            
            Spacer()
            
            // Always show the preview grid
            previewGrid
            
            Spacer()
            
            // Bottom section
            if puzzle.isPublished {
                publishedBadge
                    .padding(.bottom, 32)
            } else {
                publishButton
                    .padding(.bottom, 32)
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 24)
        .navigationTitle(puzzle.isPublished ? "Published" : "Preview")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            initializePreview()
        }
        .enableInjection()
    }
    
    // MARK: - Preview Grid
    
    @ViewBuilder
    private var previewGrid: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(Array(shuffledWords.enumerated()), id: \.element.id) { index, word in
                GameTileButton(
                    text: word.text,
                    isSelected: false,
                    isShaking: false,
                    shakeAmount: 0,
                    isDisabled: true,
                    namespace: tileNamespace,
                    tileID: word.id,
                    onTap: {}
                )
                .opacity(tilesVisible ? 1 : 0)
                .offset(y: tilesVisible ? 0 : 20)
                .animation(
                    .spring(response: 0.4, dampingFraction: 0.7)
                    .delay(Double(index) * 0.03),
                    value: tilesVisible
                )
            }
        }
    }
    
    // MARK: - Publish Button
    
    @ViewBuilder
    private var publishButton: some View {
        let isValid = validationIssues.isEmpty
        
        Button {
            if isValid {
                publishPuzzle()
            }
        } label: {
            Text(isValid ? "Publish" : "Complete all groups to publish")
                .frame(minWidth: 120)
        }
        .buttonStyle(CapsuleButtonStyle(isFilled: isValid))
        .disabled(!isValid)
    }
    
    // MARK: - Published Badge
    
    @ViewBuilder
    private var publishedBadge: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
            Text("Published")
                .fontWeight(.medium)
        }
        .font(.subheadline)
        .foregroundStyle(.secondary)
    }
    
    // MARK: - Actions
    
    private func initializePreview() {
        // Validate puzzle
        validationIssues = PuzzleValidator.validate(puzzle)
        
        // Collect all words and shuffle (include empty words for preview)
        let allWords = puzzle.groups.flatMap { $0.words }
        shuffledWords = allWords.shuffled()
        
        // Trigger staggered tile animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            tilesVisible = true
        }
    }
    
    private func publishPuzzle() {
        guard !puzzle.isPublished else { return }
        
        // Assign sequence number and set title
        let sequenceNumber = PuzzleNumberingService.nextSequenceNumber()
        puzzle.sequenceNumber = sequenceNumber
        puzzle.title = "Puzzle #\(sequenceNumber)"
        
        // Set publish metadata
        puzzle.publishedAt = Date()
        puzzle.playStatus = .notStarted
        
        // Save to SwiftData
        do {
            try modelContext.save()
            
            // Post notification to pop navigation to root
            NotificationCenter.default.post(name: .puzzlePublished, object: nil)
            
            // Dismiss back to root
            dismiss()
        } catch {
            print("Failed to publish puzzle: \(error)")
        }
    }
}

// MARK: - Notification Name Extension

extension Notification.Name {
    static let puzzlePublished = Notification.Name("puzzlePublished")
}

#Preview {
    NavigationStack {
        PuzzlePreviewView(puzzle: PuzzleFixtures.sampleCompletedPuzzle())
    }
}
