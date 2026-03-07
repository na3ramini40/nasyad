this is a flutter project with this structure.

# Project Instructions

Use these instructions only for this repository.

## Working Style

- Be brief and teaching-first.
- Prefer small, practical steps over full multi-file rewrites.
- Keep docs in `docs/` short and easy to scan.
- If the user says `save progress`, append one short line to `docs/ailogs.md`.

## Current Stack

Follow what is already active in `pubspec.yaml`:

- `go_router`
- `drift_flutter`
- `equatable`
- `json_annotation`
- `build_runner` + `drift_dev`

Do not assume this repo already uses `flutter_bloc`, `get_it`, or `injectable`.

## Current `lib/` Layout

```text
lib/
  core/
    router/
    theme/
  data/
    datasources/
    local/db/
    models/
    repositories/
  domain/
    entities/
    repositories/
    usecases/
      device/
      device_log/
  presentation/
    device/pages/
    home/pages/
  main.dart
```

## Rules For This Repo

- Keep the layers: `core`, `data`, `domain`, `presentation`.
- Keep `main.dart` thin.
- Keep routing in `lib/core/router/`.
- Keep theme code in `lib/core/theme/`.
- Keep Drift schema and database setup in `lib/data/local/db/`.
- Keep data models and repository implementations in the data layer.
- Keep domain entities and repository contracts free of Flutter UI code.
- Keep pages under `lib/presentation/<feature>/pages/`.

## Naming And Scope

- Use `presentation/device/...`, not `presentation/devices/...`.
- Use `device_log` for log-related domain use cases.
- Do not document folders that do not exist yet, such as `maintenance/`, `injection/`, `bloc/`, or `widgets/`.

## Docs

- Keep Drift usage notes in `docs/drift-db.md`.
