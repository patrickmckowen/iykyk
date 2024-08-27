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
                    .onChange(of: internalWord) { _, newValue in
                        let limitedWord = limitToTwoWords(newValue)
                        if limitedWord != newValue {
                            internalWord = limitedWord
                            isFocused = false
                        }
                        word = limitedWord
                        fontSize = adjustFontSize(for: limitedWord, in: geometry.size)
                    }
            }
            .frame(width: geometry.size.width, height: geometry.size.width)
            .onTapGesture {
                isFocused = true
            }
            .onAppear {
                internalWord = word
                fontSize = adjustFontSize(for: word, in: geometry.size)
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
