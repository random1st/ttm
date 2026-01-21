import SwiftUI
import SwiftData

struct ProjectRowView: View {
    @Environment(\.modelContext) private var modelContext
    let project: Project
    let timerManager: TimerManager
    let onDelete: () -> Void

    @State private var showingDeleteConfirm = false

    private var isRunning: Bool {
        timerManager.isRunning(project: project)
    }

    private var displayDuration: TimeInterval {
        if isRunning {
            // Force refresh via tick
            _ = timerManager.tick
            return project.todayDuration + timerManager.elapsed(project: project)
        }
        return project.todayDuration
    }

    var body: some View {
        HStack(spacing: 8) {
            // Color indicator
            Circle()
                .fill(Color(hex: project.colorHex) ?? .blue)
                .frame(width: 10, height: 10)

            // Project info
            VStack(alignment: .leading, spacing: 2) {
                Text(project.name)
                    .font(.system(.body, weight: .medium))
                    .lineLimit(1)

                Text(formattedDuration)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Timer control
            Button {
                timerManager.toggle(project: project, context: modelContext)
            } label: {
                Image(systemName: isRunning ? "pause.fill" : "play.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(isRunning ? .orange : .green)
                    .frame(width: 28, height: 28)
                    .background(
                        Circle()
                            .fill(isRunning ? Color.orange.opacity(0.15) : Color.green.opacity(0.15))
                    )
            }
            .buttonStyle(.plain)

            // Context menu
            Menu {
                Button("Reset Time", systemImage: "arrow.counterclockwise") {
                    resetProjectTime()
                }
                Button("Archive", systemImage: "archivebox") {
                    project.isArchived = true
                }
                Button("Delete", systemImage: "trash", role: .destructive) {
                    showingDeleteConfirm = true
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .frame(width: 24, height: 24)
            }
            .menuStyle(.borderlessButton)
            .menuIndicator(.hidden)
            .frame(width: 24)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isRunning ? Color.green.opacity(0.08) : Color(.controlBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isRunning ? Color.green.opacity(0.3) : .clear, lineWidth: 1)
        )
        .alert("Delete Project?", isPresented: $showingDeleteConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                onDelete()
            }
        } message: {
            Text("This will delete all time entries for \"\(project.name)\".")
        }
    }

    private var formattedDuration: String {
        let total = Int(displayDuration)
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func resetProjectTime() {
        if timerManager.isRunning(project: project) {
            timerManager.stop(project: project, context: modelContext)
        }
        for entry in project.entries {
            modelContext.delete(entry)
        }
        try? modelContext.save()
    }
}

// MARK: - Color Extension

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}
