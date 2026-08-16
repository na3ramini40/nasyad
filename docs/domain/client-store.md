# Client local store

Where: **client**. Every conforming client persists domain entities in a local store that remains the UI source of truth ([principles.md](principles.md)). Field shapes and enums: entity shards + [enums.md](enums.md).

## Rules

| Rule | Where |
|------|-------|
| Local store holds devices, device_logs, birthdays, tags, device_tags, and local-only tables (e.g. places) | client |
| Schema upgrades **preserve** existing user data — additive preferred; renames copy-forward | client |
| Due / soon / progress / remaining / target are computed at read time, never stored columns | client |
| Soft lifecycle on devices via `status` (`active` / `archived` / `deleted`) | both |
| Migration tests when user data is at risk (open old version → migrate → assert) | client |

## This repo (Flutter / Drift)

One conforming implementation — other stacks may differ, same outcomes.

| Fact | Value |
|------|-------|
| Entry | `client/lib/data/local/db/app_database.dart` |
| Current `schemaVersion` | `9` |
| Tables | `devices`, `device_logs`, `birthdays`, `places`, `tags`, `device_tags` |
| Tests | in-memory DB; migration tests under `client/test/` |
| Codegen | `dart run build_runner build --delete-conflicting-outputs` |

Layer placement for Drift code: [client-layout.md](client-layout.md). Data-safety gate: `.cursor/rules/shared/data-safety.mdc`. Index: [../domain.md](../domain.md)
