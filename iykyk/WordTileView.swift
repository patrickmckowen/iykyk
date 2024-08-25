import SwiftUI
import UIKit

struct WordTileView: View {
    @Binding var word: String
    @FocusState private var isFocused: Bool
    @State private var fontSize: CGFloat = 17
    @State private var internalWord: String = ""

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.white)

                TextField("Word", text: $internalWord, axis: .vertical)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .textInputAutocapitalization(.characters)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .font(.system(size: fontSize, weight: .bold))
                    .minimumScaleFactor(0.5)
                    .textCase(.uppercase)
                    .focused($isFocused)
                    .autocorrectionDisabled(true)
                    .foregroundColor(.primary)
                    .onChange(of: internalWord) { newValue in
                        let limitedWord = limitToTwoWords(newValue)
                        if limitedWord != newValue {
                            internalWord = limitedWord
                            isFocused = false
                        }
                        word = limitedWord
                        adjustFontSize(for: geometry.size)
                    }
            }
            .frame(width: geometry.size.width, height: geometry.size.width)
            .onTapGesture {
                isFocused = true
            }
            .onAppear {
                internalWord = word
                adjustFontSize(for: geometry.size)
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private func limitToTwoWords(_ newValue: String) -> String {
        let words = newValue.split(separator: " ", omittingEmptySubsequences: true)
        if words.count > 2 {
            return words[0 ... 1].joined(separator: " ")
        } else {
            return newValue
        }
    }

    private func adjustFontSize(for size: CGSize) {
        let maxWidth = size.width - 14
        let maxHeight = size.height - 14
        let testFont = UIFont.systemFont(ofSize: 17, weight: .bold)
        let words = word.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true)

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
            let size = (word as NSString).size(withAttributes: [.font: testFont])
            if size.width > maxWidth || size.height > maxHeight {
                fontSize = 17 * min(maxWidth / size.width, maxHeight / size.height) * 0.95
            } else {
                fontSize = 17
            }
        }
    }
}

struct WordTileView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            WordTileView(word: .constant(""))
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
