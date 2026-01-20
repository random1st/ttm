import Foundation
import AppKit

struct ExportService {
    enum ExportFormat {
        case csv
        case json
    }

    struct ExportEntry: Codable {
        let date: String
        let project: String
        let durationMinutes: Int
        let startTime: String
        let endTime: String
    }

    struct ExportData: Codable {
        let exportedAt: String
        let entries: [ExportEntry]

        enum CodingKeys: String, CodingKey {
            case exportedAt = "exported_at"
            case entries
        }
    }

    static func export(entries: [TimeEntry], format: ExportFormat) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"

        let completedEntries = entries.filter { $0.endTime != nil }

        let exportEntries = completedEntries.map { entry in
            ExportEntry(
                date: dateFormatter.string(from: entry.startTime),
                project: entry.project?.name ?? "Unknown",
                durationMinutes: Int(entry.duration / 60),
                startTime: timeFormatter.string(from: entry.startTime),
                endTime: timeFormatter.string(from: entry.endTime ?? entry.startTime)
            )
        }

        switch format {
        case .csv:
            return exportToCSV(entries: exportEntries)
        case .json:
            return exportToJSON(entries: exportEntries)
        }
    }

    private static func exportToCSV(entries: [ExportEntry]) -> String {
        var csv = "date,project,duration_minutes,start_time,end_time\n"
        for entry in entries {
            csv += "\(entry.date),\"\(entry.project)\",\(entry.durationMinutes),\(entry.startTime),\(entry.endTime)\n"
        }
        return csv
    }

    private static func exportToJSON(entries: [ExportEntry]) -> String {
        let isoFormatter = ISO8601DateFormatter()
        let data = ExportData(
            exportedAt: isoFormatter.string(from: Date()),
            entries: entries
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        guard let jsonData = try? encoder.encode(data),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return "{}"
        }
        return jsonString
    }

    static func saveToFile(content: String, format: ExportFormat) {
        let panel = NSSavePanel()
        panel.canCreateDirectories = true
        panel.showsTagField = false

        switch format {
        case .csv:
            panel.nameFieldStringValue = "time-tracker-export.csv"
            panel.allowedContentTypes = [.commaSeparatedText]
        case .json:
            panel.nameFieldStringValue = "time-tracker-export.json"
            panel.allowedContentTypes = [.json]
        }

        if panel.runModal() == .OK, let url = panel.url {
            try? content.write(to: url, atomically: true, encoding: .utf8)
        }
    }
}
