# TTM - Time Tracker for macOS

A lightweight menu bar app for tracking work time across multiple projects simultaneously.

## Features

- **Multiple Concurrent Timers** - Track time on several projects at once (perfect for the AI age when agents work in parallel)
- **Menu Bar Integration** - Lives in your menu bar, no dock icon
- **Keyboard Shortcuts** - ⌘1-9 to toggle project timers
- **Daily Summary** - See time spent per project each day
- **History View** - Browse past days and export data
- **CSV/JSON Export** - Export your time data for invoicing or analysis

## Requirements

- macOS 14.0 (Sonoma) or later

## Installation

### From Releases

1. Download the latest DMG from [Releases](https://github.com/random1st/ttm/releases)
2. Open the DMG and drag TTM to Applications
3. Launch TTM from Applications

### Build from Source

```bash
git clone https://github.com/random1st/ttm.git
cd ttm
xcodebuild -project TTM.xcodeproj -scheme TTM -configuration Release
```

## Usage

1. Click the timer icon in the menu bar
2. Add projects with the "Add Project" button
3. Click play/pause to start/stop timers
4. Use ⌘1-9 to quickly toggle timers for the first 9 projects

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| ⌘1-9 | Toggle timer for project 1-9 |
| ⌘⇧T | Show/hide TTM window |

## Tech Stack

- Swift 5.9
- SwiftUI
- SwiftData (persistence)
- macOS 14+ MenuBarExtra

## License

MIT
