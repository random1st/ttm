import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Project.createdAt, order: .reverse) private var projects: [Project]
    @State private var timerManager = TimerManager()
    @State private var selectedTab = 0
    @State private var showingAddProject = false
    @State private var newProjectName = ""

    private let appState = AppState.shared

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("TTM")
                    .font(.headline)
                    .fontWeight(.bold)

                Spacer()

                // Pin button
                Button {
                    appState.isPinned.toggle()
                } label: {
                    Image(systemName: appState.isPinned ? "pin.fill" : "pin")
                        .font(.caption)
                        .foregroundStyle(appState.isPinned ? .blue : .secondary)
                }
                .buttonStyle(.plain)
                .help(appState.isPinned ? "Unpin window" : "Pin window")

                Text(formattedTotalToday)
                    .font(.system(.body, design: .monospaced))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)

            Divider()

            // Tab picker with keyboard hints
            HStack(spacing: 4) {
                Picker("", selection: $selectedTab) {
                    Text("Projects").tag(0)
                    Text("Today").tag(1)
                    Text("History").tag(2)
                }
                .pickerStyle(.segmented)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)

            // Content
            Group {
                switch selectedTab {
                case 0:
                    ProjectListView(
                        projects: projects,
                        timerManager: timerManager,
                        showingAddProject: $showingAddProject,
                        newProjectName: $newProjectName
                    )
                case 1:
                    DailySummaryView(projects: projects)
                case 2:
                    HistoryView(projects: projects)
                default:
                    EmptyView()
                }
            }
            .frame(maxHeight: .infinity)

            Divider()

            // Footer with shortcuts hint
            HStack {
                if !timerManager.activeEntries.isEmpty {
                    Circle()
                        .fill(.green)
                        .frame(width: 8, height: 8)
                    Text("\(timerManager.activeEntries.count) running")
                        .font(.caption)
                        .foregroundStyle(.green)
                } else {
                    Text("⌘1-9 toggle timers")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }

                Spacer()

                Button {
                    timerManager.stopAll(context: modelContext)
                    NSApplication.shared.terminate(nil)
                } label: {
                    Image(systemName: "power")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .help("Quit TTM")
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .frame(width: 360, height: 500)
        .onAppear {
            timerManager.restoreActiveEntries(from: projects)
            updateAppState()
        }
        .onChange(of: timerManager.activeEntries.count) {
            updateAppState()
        }
        .onChange(of: timerManager.tick) {
            updateAppState()
        }
        .onReceive(NotificationCenter.default.publisher(for: .toggleProjectTimer)) { notification in
            handleToggleProjectTimer(notification)
        }
    }

    private var formattedTotalToday: String {
        let total = calculateTotalToday()
        return formatDuration(total)
    }

    private func calculateTotalToday() -> TimeInterval {
        var total = projects.reduce(0) { $0 + $1.todayDuration }
        // Add currently running time
        for project in projects {
            if timerManager.isRunning(project: project) {
                total += timerManager.elapsed(project: project)
            }
        }
        return total
    }

    private func formatDuration(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        return String(format: "%dh %02dm", hours, minutes)
    }

    private func updateAppState() {
        appState.updateStatus(
            activeCount: timerManager.activeEntries.count,
            totalDuration: calculateTotalToday()
        )
    }

    private func handleToggleProjectTimer(_ notification: Notification) {
        guard let index = notification.userInfo?["index"] as? Int else { return }

        let activeProjects = projects.filter { !$0.isArchived }
        guard index < activeProjects.count else { return }

        let project = activeProjects[index]
        timerManager.toggle(project: project, context: modelContext)
    }
}
