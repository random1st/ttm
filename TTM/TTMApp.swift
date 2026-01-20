import SwiftUI
import SwiftData

@main
struct TTMApp: App {
    let modelContainer: ModelContainer
    @State private var appState = AppState.shared

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
            HStack(spacing: 4) {
                Image(systemName: appState.activeCount > 0 ? "timer.circle.fill" : "timer")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(appState.activeCount > 0 ? .green : .primary)

                if !appState.menuBarTitle.isEmpty {
                    Text(appState.menuBarTitle)
                        .font(.system(.caption, design: .monospaced))
                }
            }
        }
        .menuBarExtraStyle(.window)
    }
}
