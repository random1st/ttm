import Foundation
import SwiftData

@Model
final class Project {
    var id: UUID
    var name: String
    var colorHex: String
    var isArchived: Bool
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \TimeEntry.project)
    var entries: [TimeEntry] = []

    init(
        id: UUID = UUID(),
        name: String,
        colorHex: String = "#007AFF",
        isArchived: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.colorHex = colorHex
        self.isArchived = isArchived
        self.createdAt = createdAt
    }

    var todayDuration: TimeInterval {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return entries
            .filter { calendar.startOfDay(for: $0.startTime) == today }
            .reduce(0) { $0 + $1.duration }
    }

    var totalDuration: TimeInterval {
        entries.reduce(0) { $0 + $1.duration }
    }
}
