# App Description

This application is a local-first maintenance tracking system for devices, assets, and recurring personal follow-ups.

## Acceptance Criteria

- The app must allow users to create and manage any item they want to track, including vehicles, equipment, or personal follow-up tasks.
- The app must allow users to define what should be maintained or checked for each item and how the schedule is measured, such as by time, date, or usage interval.
- The app must display a clear list of tracked items, including the latest recorded log and the current maintenance status for each item.
- The app must help users identify when maintenance, inspection, or follow-up action is due or approaching.
- The app must allow users to add logs to each tracked item so maintenance history can be reviewed over time.
- The app must use local storage only in the current phase; network sync, remote repositories, and cloud features are out of scope for now.

## Pages

- Home page: shows all tracked items with their latest log and current due status.
- Add item page: lets the user create a new tracked item and define its maintenance or check rule.
- Item details page: shows the item information, maintenance rules, latest status, and log history.
- Add log page: lets the user record a new maintenance, inspection, or follow-up log for an item.
- Preferences: language, theme, and data transfer.
- Export & Import: choose scope (all / one / selected), format (JSON / CSV / plain text), then share or save; import from a file.

## Features

- Create and manage tracked items for different use cases.
- Define custom maintenance or check schedules by time, date, or usage.
- View current maintenance status for all tracked items.
- Record logs and keep a simple local maintenance history.
- Export and import devices, rules, and logs in JSON, CSV, or plain text.
- Store all app data locally for the current version.
