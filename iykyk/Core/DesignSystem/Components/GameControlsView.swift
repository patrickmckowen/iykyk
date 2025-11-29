//
//  GameControlsView.swift
//  iykyk
//
//  Shared component for game control buttons.
//

import SwiftUI

/// A row of game control buttons: Shuffle, Deselect All, and Submit.
struct GameControlsView: View {
    let canDeselect: Bool
    let canSubmit: Bool
    let onShuffle: () -> Void
    let onDeselectAll: () -> Void
    let onSubmit: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Button("Shuffle") {
                onShuffle()
            }
            .buttonStyle(CapsuleButtonStyle())
            
            Button("Deselect all") {
                onDeselectAll()
            }
            .buttonStyle(CapsuleButtonStyle())
            .disabled(!canDeselect)
            
            Button("Submit") {
                onSubmit()
            }
            .buttonStyle(CapsuleButtonStyle(isFilled: canSubmit))
            .disabled(!canSubmit)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        GameControlsView(
            canDeselect: true,
            canSubmit: true,
            onShuffle: {},
            onDeselectAll: {},
            onSubmit: {}
        )
        
        GameControlsView(
            canDeselect: false,
            canSubmit: false,
            onShuffle: {},
            onDeselectAll: {},
            onSubmit: {}
        )
    }
    .padding()
}

