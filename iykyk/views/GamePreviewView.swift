import SwiftUI
import UIKit

struct GamePreviewView: View {
    let game: Game

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 20) {
                GameBoardView(game: game, screenWidth: geometry.size.width)

                Button(action: {
                    // TODO: Implement share functionality
                    print("Share button tapped")
                }) {
                    Text("Share")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            .padding(4)
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
            fontSize = adjustFontSize(for: word.text, in: CGSize(width: size, height: size))
        }
    }
}

struct GamePreviewView_Previews: PreviewProvider {
    static var previews: some View {
        GamePreviewView(game: Game())
    }
}
