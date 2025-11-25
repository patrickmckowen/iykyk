//
//  PuzzleRowView.swift
//  iykyk
//
//  List row component for displaying a puzzle in the library.
//

import SwiftUI

struct PuzzleRowView: View {
    let puzzle: Puzzle
    var showPlayStatus: Bool = false
    
    private var sequenceText: String {
        if let number = puzzle.sequenceNumber, number > 0 {
            return "#\(number)"
        } else {
            return "#?"
        }
    }
    
    private var wordCount: Int {
        puzzle.groups.flatMap { $0.words }.filter {
            !$0.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }.count
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .center, spacing: 8) {
                Text(sequenceText)
                    .font(.headline)
                
                // Status capsule
                Text(showPlayStatus ? puzzle.playStatus.displayText : puzzle.publishStatusText)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(statusColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(statusColor.opacity(0.15))
                    .clipShape(Capsule())
            }
            
            HStack {
                Text("\(wordCount)/16 words")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Text(dateFormatter.string(from: puzzle.createdAt))
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
    }
    
    private var statusColor: Color {
        if showPlayStatus {
            switch puzzle.playStatus {
            case .notStarted: return .blue
            case .inProgress: return .orange
            case .won: return .green
            case .lost: return .red
            }
        } else {
            return puzzle.isPublished ? .green : .secondary
        }
    }
}

#Preview {
    List {
        PuzzleRowView(puzzle: PuzzleFixtures.sampleCompletedPuzzle(), showPlayStatus: false)
        PuzzleRowView(puzzle: PuzzleFixtures.sampleCompletedPuzzle(), showPlayStatus: true)
    }
}

