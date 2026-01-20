import SwiftUI
import SwiftData

struct DayGroup: Identifiable {
    let date: String
    let entries: [TimeEntry]
    let total: TimeInterval

    var id: String { date }
}

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TimeEntry.startTime, order: .reverse) private var allEntries: [TimeEntry]
    let projects: [Project]

    @State private var selectedExportFormat: ExportService.ExportFormat = .csv

    private var groupedByDate: [DayGroup] {
        let grouped = Dictionary(grouping: allEntries) { $0.dateKey }
        return grouped
            .map { DayGroup(date: $0.key, entries: $0.value, total: $0.value.reduce(0) { $0 + $1.duration }) }
            .sorted { $0.date > $1.date }
    }

    var body: some View {
        VStack(spacing: 0) {
            if groupedByDate.isEmpty {
                emptyState
            } else {
                historyList
            }

            exportSection
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            Text("No history yet")
                .font(.headline)
            Text("Completed time entries will appear here")
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private var historyList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(groupedByDate) { group in
                    VStack(alignment: .leading, spacing: 8) {
                        // Date header
                        HStack {
                            Text(formatDateHeader(group.date))
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.secondary)

                            Spacer()

                            Text(formatDuration(group.total))
                                .font(.system(.caption, design: .monospaced))
                                .foregroundStyle(.secondary)
                        }

                        // Entries for the day
                        ForEach(group.entries) { entry in
                            HStack {
                                Circle()
                                    .fill(Color(hex: entry.project?.colorHex ?? "#888888") ?? .gray)
                                    .frame(width: 6, height: 6)

                                Text(entry.project?.name ?? "Unknown")
                                    .font(.caption)
                                    .lineLimit(1)

                                Spacer()

                                Text(formatTimeRange(entry))
                                    .font(.system(.caption2, design: .monospaced))
                                    .foregroundStyle(.tertiary)

                                Text(formatDuration(entry.duration))
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundStyle(.secondary)
                                    .frame(width: 50, alignment: .trailing)
                            }
                        }
                    }
                    .padding(10)
                    .background(Color(.controlBackgroundColor))
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
    }

    private var exportSection: some View {
        VStack(spacing: 8) {
            Divider()

            HStack(spacing: 12) {
                Picker("", selection: $selectedExportFormat) {
                    Text("CSV").tag(ExportService.ExportFormat.csv)
                    Text("JSON").tag(ExportService.ExportFormat.json)
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .frame(width: 140)

                Spacer()

                Button("Export") {
                    exportData()
                }
                .buttonStyle(.bordered)
                .disabled(allEntries.isEmpty)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
    }

    private func exportData() {
        let content = ExportService.export(entries: allEntries, format: selectedExportFormat)
        ExportService.saveToFile(content: content, format: selectedExportFormat)
    }

    private func formatDateHeader(_ dateKey: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: dateKey) else { return dateKey }

        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            formatter.dateFormat = "EEEE, MMM d"
            return formatter.string(from: date)
        }
    }

    private func formatTimeRange(_ entry: TimeEntry) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"

        let start = formatter.string(from: entry.startTime)
        let end = entry.endTime.map { formatter.string(from: $0) } ?? "now"
        return "\(start)–\(end)"
    }

    private func formatDuration(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60

        if hours > 0 {
            return String(format: "%dh %02dm", hours, minutes)
        }
        return String(format: "%dm", minutes)
    }
}
