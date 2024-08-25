import SwiftUI
import UIKit

struct GamePreviewView: View {
    let game: Game
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 20) {
                GameBoardView(game: game, screenWidth: geometry.size.width)
            }
            .padding(4)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Edit") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
            ToolbarItem(placement: .principal) {
                Text("Preview")
                    .font(.headline)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Finish") {
                    // TODO: Implement create game functionality
                    print("Create Game button tapped")
                }
            }
        }
    }
}

struct GameBoardView: View {
    let game: Game
    let screenWidth: CGFloat

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(game.allWords) { word in
                GameTileView(word: word, size: (screenWidth - 40) / 4)
            }
        }
    }
}

struct GameTileView: View {
    let word: Word
    let size: CGFloat
    @State private var fontSize: CGFloat = 17

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(uiColor: .systemGray6))
                .aspectRatio(1, contentMode: .fit)

            Text(word.text.uppercased())
                .font(.system(size: fontSize, weight: .bold))
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
                .minimumScaleFactor(0.5)
                .lineLimit(2)
        }
        .frame(width: size, height: size)
        .onAppear {
            adjustFontSize()
        }
    }

    private func adjustFontSize() {
        let maxWidth = size - 14
        let maxHeight = size - 14
        let testFont = UIFont.systemFont(ofSize: 17, weight: .bold)
        let words = word.text.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true)

        if words.count == 2 {
            // Two words: split them and calculate size
            let size1 = (words[0] as NSString).size(withAttributes: [.font: testFont])
            let size2 = (words[1] as NSString).size(withAttributes: [.font: testFont])
            let totalHeight = size1.height + size2.height
            let maxWordWidth = max(size1.width, size2.width)

            if maxWordWidth > maxWidth || totalHeight > maxHeight {
                fontSize = 17 * min(maxWidth / maxWordWidth, maxHeight / totalHeight) * 0.95
            } else {
                fontSize = 17
            }
        } else {
            // Single word
            let size = (word.text as NSString).size(withAttributes: [.font: testFont])
            if size.width > maxWidth || size.height > maxHeight {
                fontSize = 17 * min(maxWidth / size.width, maxHeight / size.height) * 0.95
            } else {
                fontSize = 17
            }
        }
    }
}

struct GamePreviewView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            GamePreviewView(game: Game())
        }
    }
}
