import SwiftUI

struct DailySummaryView: View {
    let projects: [Project]

    private var todaySummary: [(project: Project, duration: TimeInterval)] {
        projects
            .map { ($0, $0.todayDuration) }
            .filter { $0.1 > 0 }
            .sorted { $0.1 > $1.1 }
    }

    private var totalToday: TimeInterval {
        todaySummary.reduce(0) { $0 + $1.duration }
    }

    var body: some View {
        VStack(spacing: 0) {
            if todaySummary.isEmpty {
                emptyState
            } else {
                summaryContent
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "moon.zzz")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            Text("No activity today")
                .font(.headline)
            Text("Start a timer to begin tracking")
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private var summaryContent: some View {
        VStack(spacing: 16) {
            // Total card
            VStack(spacing: 4) {
                Text("Total Today")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(formatDuration(totalToday))
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color(.controlBackgroundColor))
            .cornerRadius(12)

            // Breakdown
            VStack(alignment: .leading, spacing: 8) {
                Text("Breakdown")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                ForEach(todaySummary, id: \.project.id) { item in
                    HStack {
                        Circle()
                            .fill(Color(hex: item.project.colorHex) ?? .blue)
                            .frame(width: 8, height: 8)

                        Text(item.project.name)
                            .lineLimit(1)

                        Spacer()

                        Text(formatDuration(item.duration))
                            .font(.system(.body, design: .monospaced))
                            .foregroundStyle(.secondary)

                        Text(percentageString(item.duration))
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                            .frame(width: 40, alignment: .trailing)
                    }
                }
            }
            .padding(12)
            .background(Color(.controlBackgroundColor))
            .cornerRadius(12)

            Spacer()
        }
        .padding(12)
    }

    private func formatDuration(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60

        if hours > 0 {
            return String(format: "%dh %02dm", hours, minutes)
        }
        return String(format: "%dm", minutes)
    }

    private func percentageString(_ duration: TimeInterval) -> String {
        guard totalToday > 0 else { return "0%" }
        let percentage = (duration / totalToday) * 100
        return String(format: "%.0f%%", percentage)
    }
}
