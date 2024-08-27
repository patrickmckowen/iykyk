import SwiftData
import SwiftUI

struct CreateGameView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) var presentationMode
    @State private var game = Game()

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(game.threads.indices, id: \.self) { index in
                    ThreadInputView(thread: $game.threads[index])
                }
            }
            .padding(4)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Finish") {
                    saveGame()
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }

    private func saveGame() {
        modelContext.insert(game)
        do {
            try modelContext.save()
        } catch {
            print("Error saving game: \(error)")
        }
    }
}

struct CreateGameView_Previews: PreviewProvider {
    static var previews: some View {
        CreateGameView()
    }
}
