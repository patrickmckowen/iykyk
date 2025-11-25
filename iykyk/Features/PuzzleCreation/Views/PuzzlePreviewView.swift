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
    
    @State private var titleText: String = ""
    @State private var shuffledWords: [PuzzleWord] = []
    @State private var validationIssues: [ValidationIssue] = []
    @State private var tilesVisible: Bool = false
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @FocusState private var isTitleFocused: Bool
    @ObserveInjection private var inject
    
    private let titleCharacterLimit = 50
    
    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 8), count: 4)
    }
    
    var body: some View {
        VStack(spacing: 24) {
            if validationIssues.isEmpty {
                // Title section
                titleSection
                
                Spacer()
                
                // Static preview grid
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
            } else {
                // Validation errors
                validationErrorsView
            }
        }
        .padding(.horizontal)
        .padding(.top, 24)
        .navigationTitle(puzzle.isPublished ? "Published" : "Preview")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .contentShape(Rectangle())
        .onTapGesture {
            isTitleFocused = false
        }
        .onAppear {
            initializePreview()
        }
        .enableInjection()
    }
    
    // MARK: - Title Section
    
    @ViewBuilder
    private var titleSection: some View {
        VStack(spacing: 8) {
            if puzzle.isPublished {
                // Read-only title for published puzzles
                Text(puzzle.displayTitle)
                    .font(.title.bold())
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)
            } else {
                // Editable title for unpublished puzzles
                TextField("Enter a title...", text: $titleText)
                    .font(.title.bold())
                    .multilineTextAlignment(.center)
                    .textFieldStyle(.plain)
                    .focused($isTitleFocused)
                    .onChange(of: titleText) { _, newValue in
                        // Enforce character limit
                        if newValue.count > titleCharacterLimit {
                            titleText = String(newValue.prefix(titleCharacterLimit))
                        }
                        // Sync to model
                        puzzle.title = titleText
                    }
                
                // Character count (show when approaching limit)
                if titleText.count > titleCharacterLimit - 10 {
                    Text("\(titleText.count)/\(titleCharacterLimit)")
                        .font(.caption)
                        .foregroundStyle(titleText.count >= titleCharacterLimit ? .orange : .secondary)
                        .transition(.opacity)
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: titleText.count > titleCharacterLimit - 10)
    }
    
    // MARK: - Preview Grid
    
    @ViewBuilder
    private var previewGrid: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(Array(shuffledWords.enumerated()), id: \.element.id) { index, word in
                PreviewTile(text: word.text)
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
        Button {
            publishPuzzle()
        } label: {
            Text("Publish")
                .frame(minWidth: 120)
        }
        .buttonStyle(CapsuleButtonStyle(isFilled: true))
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
    
    // MARK: - Validation Errors
    
    @ViewBuilder
    private var validationErrorsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundStyle(.orange)
            
            Text("Puzzle Needs Fixes")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(validationIssues) { issue in
                    HStack(alignment: .top) {
                        Text("•")
                        Text(issue.message)
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            Text("Please return to editing and complete all groups.")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    // MARK: - Actions
    
    private func initializePreview() {
        // Validate puzzle first
        validationIssues = PuzzleValidator.validate(puzzle)
        
        guard validationIssues.isEmpty else { return }
        
        // Initialize title from puzzle
        titleText = puzzle.title == "New Puzzle" ? "" : puzzle.title
        
        // Collect all words and shuffle
        let allWords = puzzle.groups.flatMap { $0.words }
        shuffledWords = allWords.shuffled()
        
        // Trigger staggered tile animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            tilesVisible = true
        }
    }
    
    private func publishPuzzle() {
        guard !puzzle.isPublished else { return }
        
        // If title is empty, set default based on sequence number
        if titleText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let sequenceNumber = PuzzleNumberingService.nextSequenceNumber()
            puzzle.sequenceNumber = sequenceNumber
            puzzle.title = "Puzzle #\(sequenceNumber)"
        } else {
            puzzle.sequenceNumber = PuzzleNumberingService.nextSequenceNumber()
            puzzle.title = titleText
        }
        
        // Set publish metadata
        puzzle.publishedAt = Date()
        puzzle.playStatus = .notStarted
        
        // Save to SwiftData
        do {
            try modelContext.save()
            
            // Post notification for success banner
            NotificationCenter.default.post(
                name: .puzzlePublished,
                object: nil,
                userInfo: ["puzzleTitle": puzzle.displayTitle]
            )
            
            // Dismiss back to root
            dismiss()
        } catch {
            print("Failed to publish puzzle: \(error)")
        }
    }
}

// MARK: - Preview Tile Component

private struct PreviewTile: View {
    let text: String
    
    var body: some View {
        GeometryReader { geometry in
            AutoSizingTileText(text: text, containerSize: geometry.size)
                .foregroundStyle(Color.primary)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(Color(.systemGray4), lineWidth: 1)
                        )
                )
        }
        .frame(height: 80)
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
