//
//  ThreadInputView.swift
//  iykyk
//
//  Created by Patrick McKowen on 8/25/24.
//
import SwiftUI


struct ThreadInputView: View {
    @Binding var thread: Thread

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                Circle()
                    .fill(thread.color)
                    .frame(width: 8, height: 8)
                TextField("Thread description", text: $thread.name)
            }
            .font(.title2)
            .padding(.horizontal, 4)
            .padding(.vertical, 4)
            .autocorrectionDisabled(true)
            .textInputAutocapitalization(.never)

            HStack(spacing: 4) {
                ForEach(thread.words.indices, id: \.self) { index in
                    WordTileView(word: $thread.words[index].text)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(8)
        .background(Color(UIColor.systemGray6))
        .border(Color.gray.opacity(0.2), width: 0.5)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .cornerRadius(16)
    }
}
