this is a flutter project with this structure.

# Project Instructions

Use these instructions only for this repository.

## Working Style

- Be brief and teaching-first.
- Prefer small, practical steps over full multi-file rewrites.
- Keep docs in `docs/` short and easy to scan.
- Feature delivery: [`.cursor/AGENTS.md`](../.cursor/AGENTS.md) → Feature Delivery Manager.
- Save progress: [`.cursor/commands/save-progress.md`](../.cursor/commands/save-progress.md).
- CI before PR: [`.cursor/rules/ci-before-pr.mdc`](../.cursor/rules/ci-before-pr.mdc).

## Current Stack

Follow what is already active in `pubspec.yaml`:

- `go_router`
- `drift_flutter`
- `flutter_bloc`
- `equatable`
- `json_annotation`
- `build_runner` + `drift_dev`
- `flutter_localizations` + `intl` (en / fa)
- `share_plus`, `path_provider`, `file_selector` (export / import)
- `shared_preferences` (last-seen app version, calendar preference)
- `shamsi_date` (Persian calendar month/day conversion)
- `http`, `crypto` (GitHub release checks and in-app updates only)
- `firebase_core`, `firebase_messaging`, `flutter_local_notifications` (push notifications; Android/iOS/macOS only — skipped on Linux)

Do not assume this repo already uses `get_it` or `injectable`.

## Current `lib/` Layout

```text
lib/
  core/
    router/
    theme/
    ui/
    l10n/
    utils/
    version/
    calendar/
    app_services.dart
  l10n/
  data/
    datasources/
    local/db/
    models/
    repositories/
  domain/
    entities/
    repositories/
    services/
    usecases/
      device/
      device_log/
      transfer/
      birthday/
  presentation/
    splash/
      bloc/
      pages/
    home/
      bloc/
      pages/
    device/
      bloc/
      pages/
    preferences/pages/
    app_update/
      bloc/
      widgets/
    transfer/
      bloc/
      pages/
    birthday/
      bloc/
      pages/
  main.dart
```

## Rules For This Repo

- Keep the layers: `core`, `data`, `domain`, `presentation`.
- Keep `main.dart` thin.
- Keep routing in `lib/core/router/`.
- Keep theme tokens and `ThemeData` in `lib/core/theme/`.
- Keep shared design-system widgets in `lib/core/ui/` (buttons, badges, fields, cards, responsive helpers). Prefer theme tokens over hard-coded styles.
- Keep UI strings in `lib/l10n/` ARB files (`app_en.arb`, `app_fa.arb`). Use `AppLocalizations.of(context)`; do not hard-code user-facing English/Persian text in widgets.
- Supported locales: English (`en`) and Persian (`fa`, RTL). Switch via `LocaleCubit` on Preferences.
- Theme mode (system / light / dark) via `ThemeModeCubit` on Preferences.
- Calendar system (Gregorian / Persian) via `CalendarSystemCubit` on Preferences — independent of language.
- Feature state lives in `presentation/<feature>/bloc/` using `flutter_bloc` (Bloc or Cubit). Pages listen/build from blocs; do not call use cases directly from widgets.
- Keep Drift schema and database setup in `lib/data/local/db/`.
- Keep data models and repository implementations in the data layer.
- Keep domain entities and repository contracts free of Flutter UI code.
- Keep pages under `lib/presentation/<feature>/pages/`.

## Naming And Scope

- Use `presentation/device/...`, not `presentation/devices/...`.
- Use `device_log` for log-related domain use cases.
- Do not document folders that do not exist yet, such as `maintenance/` or `injection/`.

## Docs

- Keep Drift usage notes in `docs/drift-db.md`.
