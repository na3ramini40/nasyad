---
name: nasyad-flutter
description: Senior Flutter development for the Nasyad local-first maintenance app. Enforces clean architecture, active stack only, and docs-backed patterns. Use when writing, reviewing, or refactoring Dart/Flutter code in this repo, or when the user asks about architecture, Drift, routing, or features.
---

# Nasyad Flutter

Act as a senior Flutter engineer on this repo. Be direct, short, and robust. Prefer small practical steps. Teach briefly when it helps.

**Authority order:** `docs/AGENTS.md` > `pubspec.yaml` > other `docs/`. Do not invent layers, packages, or folders that are not active.

## Product

Local-first maintenance tracker for devices/assets and recurring follow-ups. Local storage only; no network sync or cloud in this phase.

Pages: home (items + latest log + due status), add item, item details, add log.

Details: [docs/app-description.md](../../../docs/app-description.md)

## Stack (active only)

From `pubspec.yaml` — use these, nothing else by default:

| Concern | Package |
|---------|---------|
| Routing | `go_router` |
| Local DB | `drift_flutter` + `drift_dev` |
| State | `flutter_bloc` |
| Models | `equatable`, `json_annotation` |
| Transfer | `share_plus`, `path_provider`, `file_selector` |
| Prefs | `shared_preferences` (last-seen version / What's New) |
| Codegen | `build_runner` |
| i18n | `flutter_localizations` + `intl` (`en`, `fa`) |

**Do not assume** `get_it`, `injectable`, `freezed`, or network clients unless the user adds them and updates docs.

After Drift schema/DAO/annotation changes:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Drift patterns: [docs/drift-db.md](../../../docs/drift-db.md)

## Architecture

Layers and dependency direction:

```text
presentation → domain ← data
       ↘       core       ↙
```

| Layer | Owns | Must not |
|-------|------|----------|
| `core` | router, theme, shared UI (`ui/`), utils | feature-only code |
| `domain` | entities, repo contracts, use cases | Flutter UI, Drift |
| `data` | Drift DB/DAOs, models, repo impls, datasources | widgets |
| `presentation` | pages, feature blocs/cubits | DB tables, raw Drift |

Rules:

- Keep `main.dart` thin.
- Routing → `lib/core/router/`
- Theme → `lib/core/theme/`
- Shared design-system widgets → `lib/core/ui/`
- Drift schema/setup → `lib/data/local/db/`
- Pages → `lib/presentation/<feature>/pages/`
- Feature BLoCs → `lib/presentation/<feature>/bloc/`
- Pages use blocs; do not call use cases from widgets.
- Map models → entities at the repository boundary.
- One use case = one business action.

Layout truth: [docs/AGENTS.md](../../../docs/AGENTS.md). Folder intent: [docs/lib-folder-structure.md](../../../docs/lib-folder-structure.md) — ignore aspirational folders not listed in AGENTS (`injection/`, `maintenance/` until they exist).

## Naming

- `presentation/device/...` — not `devices`
- Log use cases under `domain/usecases/device_log/`
- Singular feature folders; match existing file naming

## Coding standards

- Clean, minimal, review-ready Dart. No comments unless asked.
- Prefer composition over inheritance; keep widgets focused.
- Handle loading / empty / error UI explicitly.
- Validate at use-case or form boundary; fail clearly.
- Never edit `*.g.dart`.
- Prefer `const` where cheap; avoid premature abstractions.
- Do not scatter Drift queries — DAOs/datasources/repos only.
- Schema change → bump `schemaVersion`; migrate carefully if local data matters.

## Workflow

1. Read relevant `docs/` + existing code in the touched layer.
2. Change the smallest surface that solves the request.
3. Keep layers and naming intact.
4. Run codegen when Drift/annotations change.
5. If user says `save progress`, append one short line to `docs/ailogs.md`.

## Docs hygiene

Keep `docs/` short and scannable. Drift notes stay in `docs/drift-db.md`. Do not document folders that do not exist yet.
