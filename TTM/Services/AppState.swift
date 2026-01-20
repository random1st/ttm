import Foundation
import SwiftUI
import SwiftData
import Observation
import Carbon.HIToolbox

@Observable
final class AppState {
    static let shared = AppState()

    var activeCount: Int = 0
    var totalTodayDuration: TimeInterval = 0
    var isPinned: Bool = false

    private var globalMonitor: Any?
    private var localMonitor: Any?

    private init() {
        setupGlobalShortcuts()
    }

    func updateStatus(activeCount: Int, totalDuration: TimeInterval) {
        self.activeCount = activeCount
        self.totalTodayDuration = totalDuration
    }

    var menuBarTitle: String {
        if activeCount > 0 {
            let hours = Int(totalTodayDuration) / 3600
            let minutes = (Int(totalTodayDuration) % 3600) / 60
            return "\(activeCount)↑ \(hours):\(String(format: "%02d", minutes))"
        }
        return ""
    }

    // MARK: - Global Keyboard Shortcuts

    private func setupGlobalShortcuts() {
        // Global monitor for when app is not focused
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.handleKeyEvent(event)
        }

        // Local monitor for when app is focused
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if self?.handleKeyEvent(event) == true {
                return nil // Consume the event
            }
            return event
        }
    }

    @discardableResult
    private func handleKeyEvent(_ event: NSEvent) -> Bool {
        // Check for ⌘⇧T to toggle popover visibility
        if event.modifierFlags.contains([.command, .shift]) && event.keyCode == kVK_ANSI_T {
            NotificationCenter.default.post(name: .togglePopover, object: nil)
            return true
        }

        // Check for ⌘1-9 to toggle project timers
        if event.modifierFlags.contains(.command) && !event.modifierFlags.contains(.shift) {
            let keyCode = event.keyCode
            // Key codes for 1-9
            let numberKeyCodes: [UInt16] = [
                UInt16(kVK_ANSI_1), UInt16(kVK_ANSI_2), UInt16(kVK_ANSI_3),
                UInt16(kVK_ANSI_4), UInt16(kVK_ANSI_5), UInt16(kVK_ANSI_6),
                UInt16(kVK_ANSI_7), UInt16(kVK_ANSI_8), UInt16(kVK_ANSI_9)
            ]

            if let index = numberKeyCodes.firstIndex(of: keyCode) {
                NotificationCenter.default.post(
                    name: .toggleProjectTimer,
                    object: nil,
                    userInfo: ["index": index]
                )
                return true
            }
        }

        return false
    }

    deinit {
        if let monitor = globalMonitor {
            NSEvent.removeMonitor(monitor)
        }
        if let monitor = localMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let togglePopover = Notification.Name("togglePopover")
    static let toggleProjectTimer = Notification.Name("toggleProjectTimer")
}
