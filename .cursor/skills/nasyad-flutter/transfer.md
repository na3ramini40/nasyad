# Transfer (export / import)

Local backup and move — no cloud sync.

## Packages

`share_plus`, `path_provider`, `file_selector` — see `stack.md`.

## Feature location

- Presentation: `lib/presentation/transfer/`
- Domain: `lib/domain/usecases/transfer/`
- Entry: Preferences → Export & import

## Export scopes

- All data / one device / selected devices
- Formats: JSON, CSV, plain text (per product map)

## Import

- File picker → validate → merge/replace per existing use-case logic
- **High stakes** — UX must state consequences (see `end-user.md` Learned)

## UX gates

- Confirm destructive or overwrite paths.
- Snackbar feedback on success/failure; stay on Preferences.

## Engineering gates

- Keep IO in data layer / use cases — not in widgets.
- Schema changes affect export shape — bump version + migration when breaking.

See `app-map.md` → Preferences → Export & import for user-visible behavior.
