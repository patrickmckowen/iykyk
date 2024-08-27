import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var games: [Game]

    var body: some View {
        NavigationView {
            Group {
                if games.isEmpty {
                    VStack(spacing: 20) {
                        Text("Create your first Game")
                            .font(.title2)
                            .foregroundColor(.secondary)

                        NavigationLink(destination: CreateGameView()) {
                            Label("New Game", systemImage: "plus")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                } else {
                    List {
                        ForEach(games) { game in
                            NavigationLink(destination: GamePreviewView(game: game)) {
                                Text("Game \(game.id.uuidString.prefix(8))")
                                    .padding(.vertical, 8)
                            }
                        }
                        .onDelete(perform: deleteGames)
                    }
                    .listStyle(InsetGroupedListStyle())
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: CreateGameView()) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }

    private func deleteGames(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(games[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Game.self, inMemory: true)
}
