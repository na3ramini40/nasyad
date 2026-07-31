# App Description

This application is a local-first maintenance tracking system for devices, assets, and recurring personal follow-ups.

## Acceptance Criteria

- The app must allow users to create and manage tracked items in a **tree** (a device may have children, and children may have children).
- Any node may optionally define its own maintenance schedule (time, usage, or fixed date), including an initial “already elapsed” offset.
- Usage-based schedules share a single usage reading on the nearest usage-owner ancestor (e.g. car odometer); calendar schedules progress by wall clock.
- The app must display root items on Home with aggregate due status and a progress bar.
- Opening a device shows its schedule progress, nested children, and log history.
- Users can update usage (absolute reading) or mark a node as maintained (resets that node’s cycle only).
- Archive / delete cascades to the entire subtree.
- The app must use local storage only in the current phase; network sync, remote repositories, and cloud features are out of scope for now.

## Pages

- Home page: root devices with latest log and aggregate due status + progress.
- Add / edit device: name, optional schedule, initial elapsed, optional usage unit (roots).
- Device details: status bar, schedule, children, logs; add child; add log.
- Add log: maintenance done or usage update.
- Preferences: language, theme, and data transfer.
- Export & Import: choose scope (all / one / selected), format (JSON / CSV / plain text), then share or save; import from a file.

## Features

- Hierarchical devices (parts under assets).
- One optional schedule per device node.
- Clear progress toward due for each scheduled node / aggregated parents.
- Local export and import of devices and logs.
- Store all app data locally for the current version.
