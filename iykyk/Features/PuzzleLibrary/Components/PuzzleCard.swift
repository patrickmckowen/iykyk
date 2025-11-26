//
//  PuzzleCard.swift
//  iykyk
//
//  Card component for displaying a puzzle in the library.
//

import SwiftUI
import Inject

struct PuzzleCard: View {
    let puzzle: Puzzle
    var showPlayStatus: Bool = false
    
    @ObserveInjection private var inject
    @Environment(\.colorScheme) private var colorScheme
    
    private var sequenceText: String {
        if let number = puzzle.sequenceNumber, number > 0 {
            return "#\(number)"
        } else {
            return "#?"
        }
    }
    
    /// Title text for the card - differs between Play and Create modes
    private var titleText: String {
        if showPlayStatus {
            // Play mode: "Puzzle #N"
            return "Puzzle \(sequenceText)"
        } else {
            // Create mode: word preview
            return puzzle.wordPreview
        }
    }
    
    /// Metadata text for the card - differs between Play and Create modes
    private var metadataText: String {
        if showPlayStatus {
            // Play mode: just the published date
            if let publishedAt = puzzle.publishedAt {
                return publishedAt.relativeFormat()
            } else {
                return "Not published"
            }
        } else {
            // Create mode: sequence number + created time
            let timeText = puzzle.createdAt.relativeFormat()
            return "\(sequenceText) · \(timeText)"
        }
    }
    
    /// Groups to show as completed in thumbnail - differs between Play and Create modes
    private var thumbnailCompletedGroups: Set<Int> {
        if showPlayStatus {
            // Play mode: show solved groups during gameplay
            return puzzle.solvedGroupPositions
        } else {
            // Create mode: show groups with all words filled
            return puzzle.completedGroupPositions
        }
    }
    
    private var cardBackground: Color {
        colorScheme == .dark
            ? Color.white.opacity(0.05)
            : Color.black.opacity(0.03)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Left: Thumbnail showing group completion progress
            PuzzleThumbnail(
                isPublished: showPlayStatus ? false : puzzle.isPublished,
                completedGroups: thumbnailCompletedGroups
            )
            
            // Center: Title + Metadata
            VStack(alignment: .leading, spacing: 4) {
                // Title - differs between Play and Create modes
                Text(titleText)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                
                // Metadata line with status badge
                HStack(spacing: 6) {
                    Text(metadataText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    if showPlayStatus {
                        // Play mode: show play status (except for won)
                        if puzzle.playStatus != .won {
                            statusBadge(text: playStatusInfo.0, color: playStatusInfo.1)
                        }
                    } else {
                        // Create mode: show draft/published status
                        statusBadge(text: publishStatusInfo.0, color: publishStatusInfo.1)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .enableInjection()
    }
    
    @ViewBuilder
    private func statusBadge(text: String, color: Color) -> some View {
        Text(text)
            .font(.caption2)
            .fontWeight(.medium)
            .foregroundStyle(color)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(color.opacity(0.15))
            .clipShape(Capsule())
    }
    
    private var playStatusInfo: (String, Color) {
        switch puzzle.playStatus {
        case .notStarted:
            return ("New", .blue)
        case .inProgress:
            return ("Playing", .orange)
        case .won:
            return ("Won", .green)
        case .lost:
            return ("Lost", .red)
        }
    }
    
    private var publishStatusInfo: (String, Color) {
        puzzle.isPublished
            ? ("Published", .green)
            : ("Draft", .secondary)
    }
}

// MARK: - ButtonStyle for Press Animation

struct PuzzleCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 12) {
            // Create mode examples
            Text("Create Tab")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            PuzzleCard(puzzle: PuzzleFixtures.sampleEmptyPuzzle(), showPlayStatus: false)
            PuzzleCard(puzzle: PuzzleFixtures.samplePartialPuzzle(), showPlayStatus: false)
            PuzzleCard(puzzle: PuzzleFixtures.sampleCompletedPuzzle(), showPlayStatus: false)
            
            Divider()
                .padding(.vertical, 8)
            
            // Play mode examples
            Text("Play Tab")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            // Not started
            PuzzleCard(
                puzzle: PuzzleFixtures.samplePublishedPuzzle(
                    playStatus: .notStarted,
                    sequenceNumber: 5
                ),
                showPlayStatus: true
            )
            
            // In progress with 2 groups solved
            PuzzleCard(
                puzzle: PuzzleFixtures.samplePublishedPuzzle(
                    playStatus: .inProgress,
                    sequenceNumber: 4,
                    solvedGroupPositions: [0, 1]
                ),
                showPlayStatus: true
            )
            
            // Won with all groups solved
            PuzzleCard(
                puzzle: PuzzleFixtures.samplePublishedPuzzle(
                    playStatus: .won,
                    sequenceNumber: 3,
                    solvedGroupPositions: [0, 1, 2, 3]
                ),
                showPlayStatus: true
            )
            
            // Lost with 1 group solved
            PuzzleCard(
                puzzle: PuzzleFixtures.samplePublishedPuzzle(
                    playStatus: .lost,
                    sequenceNumber: 2,
                    solvedGroupPositions: [0]
                ),
                showPlayStatus: true
            )
        }
        .padding(.horizontal, 16)
    }
}

