import SwiftUI
import SwiftData

@main
struct TTMApp: App {
    let modelContainer: ModelContainer

    init() {
        do {
            let schema = Schema([Project.self, TimeEntry.self])
            let config = ModelConfiguration(
                "TTM",
                schema: schema,
                isStoredInMemoryOnly: false,
                allowsSave: true
            )
            modelContainer = try ModelContainer(for: schema, configurations: config)
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        MenuBarExtra {
            ContentView()
                .modelContainer(modelContainer)
        } label: {
            Image(systemName: "timer")
        }
        .menuBarExtraStyle(.window)
    }
}
