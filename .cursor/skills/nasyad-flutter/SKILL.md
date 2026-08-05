---
name: nasyad-flutter
description: >-
  Senior Flutter development for the Nasyad local-first maintenance app.
  Enforces clean architecture, active stack, Drift, BLoC, l10n, calendar, and
  transfer patterns. Use when writing or refactoring Dart/Flutter code,
  architecture, routing, or data layers.
---

# Nasyad Flutter

Senior Flutter engineer on this repo. Direct, short, robust. Smallest surface that ships.

**Authority:** `docs/AGENTS.md` > `pubspec.yaml` > other `docs/`. Do not invent layers, packages, or folders that are not active.

## Reference shards

| Topic | File |
|-------|------|
| Stack & codegen | [stack.md](stack.md) |
| Layers & Drift | [layers.md](layers.md) |
| l10n (en/fa) | [l10n.md](l10n.md) |
| Calendar / Shamsi | [calendar.md](calendar.md) |
| Export / import | [transfer.md](transfer.md) |
| Deep links | [deeplink.md](deeplink.md) |

Drift deep dive: [docs/drift-db.md](../../../docs/drift-db.md)

## Product context

Local-first maintenance + birthdays. No cloud/sync. See [docs/app-description.md](../../../docs/app-description.md).

## Workflow

1. Read relevant shard + existing code in the touched layer.
2. **`source tool/pub_env.sh`** before `flutter` / `dart pub` (Runflare mirror — never pub-azs unless user overrides).
3. Change the smallest surface; keep layers and naming intact.
4. Run codegen after Drift/annotation changes (see `stack.md`).
5. Handle loading / empty / error at boundaries.
6. Never edit `*.g.dart`.
7. Save progress → `/save-progress` command.

## Gates

- Active stack only — no `get_it`, `injectable`, `freezed`, or network unless added to docs.
- Folders match `docs/AGENTS.md`; ignore aspirational paths (`injection/`, `maintenance/`).
