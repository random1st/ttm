import Foundation
import SwiftData

@Model
final class TimeEntry {
    var id: UUID
    var project: Project?
    var startTime: Date
    var endTime: Date?

    init(
        id: UUID = UUID(),
        project: Project? = nil,
        startTime: Date = Date(),
        endTime: Date? = nil
    ) {
        self.id = id
        self.project = project
        self.startTime = startTime
        self.endTime = endTime
    }

    var duration: TimeInterval {
        let end = endTime ?? Date()
        return end.timeIntervalSince(startTime)
    }

    var isRunning: Bool {
        endTime == nil
    }

    var dateKey: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: startTime)
    }
}
