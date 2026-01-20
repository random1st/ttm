import Foundation
import SwiftData
import Observation

@Observable
final class TimerManager {
    private(set) var activeEntries: [UUID: TimeEntry] = [:]
    private var displayTimer: Timer?
    private(set) var tick: Int = 0

    func start(project: Project, context: ModelContext) {
        guard activeEntries[project.id] == nil else { return }

        let entry = TimeEntry(project: project, startTime: Date())
        context.insert(entry)
        try? context.save()
        activeEntries[project.id] = entry

        startDisplayTimerIfNeeded()
    }

    func stop(project: Project, context: ModelContext) {
        guard let entry = activeEntries[project.id] else { return }

        entry.endTime = Date()
        try? context.save()
        activeEntries.removeValue(forKey: project.id)

        stopDisplayTimerIfNeeded()
    }

    func toggle(project: Project, context: ModelContext) {
        if isRunning(project: project) {
            stop(project: project, context: context)
        } else {
            start(project: project, context: context)
        }
    }

    func isRunning(project: Project) -> Bool {
        activeEntries[project.id] != nil
    }

    func elapsed(project: Project) -> TimeInterval {
        guard let entry = activeEntries[project.id] else {
            return 0
        }
        return entry.duration
    }

    func stopAll(context: ModelContext) {
        for (projectId, entry) in activeEntries {
            entry.endTime = Date()
        }
        activeEntries.removeAll()
        stopDisplayTimerIfNeeded()
    }

    func restoreActiveEntries(from projects: [Project]) {
        activeEntries.removeAll()

        for project in projects {
            if let runningEntry = project.entries.first(where: { $0.isRunning }) {
                activeEntries[project.id] = runningEntry
            }
        }

        if !activeEntries.isEmpty {
            startDisplayTimerIfNeeded()
        }
    }

    private func startDisplayTimerIfNeeded() {
        guard displayTimer == nil else { return }

        displayTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick += 1
        }
    }

    private func stopDisplayTimerIfNeeded() {
        guard activeEntries.isEmpty else { return }

        displayTimer?.invalidate()
        displayTimer = nil
    }

    deinit {
        displayTimer?.invalidate()
    }
}
