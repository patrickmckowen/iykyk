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
    
    private var metadataText: String {
        let timeText = puzzle.createdAt.relativeFormat()
        return "\(sequenceText) · \(timeText)"
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
                isPublished: puzzle.isPublished,
                completedGroups: puzzle.completedGroupPositions
            )
            
            // Center: Words + Metadata
            VStack(alignment: .leading, spacing: 4) {
                // Word preview - using New York serif font
                Text(puzzle.wordPreview)
                    .font(.custom("NewYork-Semibold", size: 16, relativeTo: .headline))
                    .fontWeight(.semibold)
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
            PuzzleCard(puzzle: PuzzleFixtures.sampleEmptyPuzzle(), showPlayStatus: false)
            PuzzleCard(puzzle: PuzzleFixtures.samplePartialPuzzle(), showPlayStatus: false)
            PuzzleCard(puzzle: PuzzleFixtures.sampleCompletedPuzzle(), showPlayStatus: false)
            
            Divider()
                .padding(.vertical, 8)
            
            // Play mode examples
            PuzzleCard(puzzle: PuzzleFixtures.sampleCompletedPuzzle(), showPlayStatus: true)
        }
        .padding(.horizontal, 16)
    }
}

