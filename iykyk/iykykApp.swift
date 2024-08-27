import SwiftData
import SwiftUI

@main
struct iykykApp: App {
    let container: ModelContainer

    init() {
        do {
            container = try ModelContainer(for: Game.self, Thread.self, Word.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error.localizedDescription)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
