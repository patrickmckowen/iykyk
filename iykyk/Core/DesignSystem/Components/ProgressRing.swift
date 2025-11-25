//
//  ProgressRing.swift
//  iykyk
//
//  Circular progress indicator for word completion or checkmark for published puzzles.
//

import SwiftUI

struct ProgressRing: View {
    let progress: Double // 0.0 to 1.0
    let isComplete: Bool
    var size: CGFloat = 28
    var lineWidth: CGFloat = 3
    
    @Environment(\.colorScheme) private var colorScheme
    
    private var trackColor: Color {
        colorScheme == .dark
            ? Color.white.opacity(0.1)
            : Color.black.opacity(0.08)
    }
    
    private var progressColor: Color {
        if isComplete {
            return .green
        }
        return colorScheme == .dark
            ? Color.white.opacity(0.5)
            : Color.black.opacity(0.4)
    }
    
    var body: some View {
        if isComplete {
            // Show checkmark for complete/published puzzles
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: size * 0.85, weight: .medium))
                .foregroundStyle(.green.opacity(0.7))
                .frame(width: size, height: size)
        } else {
            // Show progress ring
            ZStack {
                // Track
                Circle()
                    .stroke(trackColor, lineWidth: lineWidth)
                
                // Progress
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(progressColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    .rotationEffect(.degrees(-90))
            }
            .frame(width: size, height: size)
        }
    }
}

#Preview {
    HStack(spacing: 24) {
        VStack {
            ProgressRing(progress: 0, isComplete: false)
            Text("0/16")
                .font(.caption)
        }
        VStack {
            ProgressRing(progress: 0.25, isComplete: false)
            Text("4/16")
                .font(.caption)
        }
        VStack {
            ProgressRing(progress: 0.5, isComplete: false)
            Text("8/16")
                .font(.caption)
        }
        VStack {
            ProgressRing(progress: 1.0, isComplete: false)
            Text("16/16")
                .font(.caption)
        }
        VStack {
            ProgressRing(progress: 1.0, isComplete: true)
            Text("Published")
                .font(.caption)
        }
    }
    .padding()
}

