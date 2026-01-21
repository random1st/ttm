import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Project.createdAt, order: .reverse) private var projects: [Project]
    @State private var timerManager = TimerManager()
    @State private var selectedTab = 0
    @State private var showingAddProject = false
    @State private var newProjectName = ""
    @State private var resetConfirmStep = 0  // 0=hidden, 1=confirm, 2=confirmed

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("TTM")
                    .font(.headline)
                    .fontWeight(.bold)

                Spacer()

                Text(formattedTotalToday)
                    .font(.system(.body, design: .monospaced))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)

            Divider()

            // Tab picker
            Picker("", selection: $selectedTab) {
                Text("Projects").tag(0)
                Text("Today").tag(1)
                Text("History").tag(2)
            }
            .pickerStyle(.segmented)
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

            // Footer
            HStack {
                if resetConfirmStep == 1 {
                    Text("Reset all?")
                        .font(.caption)
                        .foregroundStyle(.red)
                    Button("Yes") {
                        resetAllData()
                        resetConfirmStep = 0
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                    .controlSize(.small)
                    Button("No") {
                        resetConfirmStep = 0
                    }
                    .controlSize(.small)
                } else {
                    if !timerManager.activeEntries.isEmpty {
                        Circle()
                            .fill(.green)
                            .frame(width: 8, height: 8)
                        Text("\(timerManager.activeEntries.count) running")
                            .font(.caption)
                            .foregroundStyle(.green)
                    }

                    Spacer()

                    Button {
                        resetConfirmStep = 1
                    } label: {
                        Image(systemName: "trash")
                            .foregroundStyle(.red.opacity(0.7))
                    }
                    .buttonStyle(.plain)
                    .help("Reset all data")

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
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .frame(width: 360, height: 500)
        .onAppear {
            timerManager.restoreActiveEntries(from: projects)
        }
    }

    private var formattedTotalToday: String {
        let total = calculateTotalToday()
        return formatDuration(total)
    }

    private func calculateTotalToday() -> TimeInterval {
        var total = projects.reduce(0) { $0 + $1.todayDuration }
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

    private func resetAllData() {
        timerManager.stopAll(context: modelContext)
        for project in projects {
            modelContext.delete(project)
        }
        try? modelContext.save()
    }
}
