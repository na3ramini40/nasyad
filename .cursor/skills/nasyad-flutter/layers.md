# Layers and Drift

## Dependency direction

```text
presentation → domain ← data
       ↘       core       ↙
```

| Layer | Owns | Must not |
|-------|------|----------|
| `core` | router, theme, shared UI, utils, calendar, version | feature-only code |
| `domain` | entities, repo contracts, use cases, services | Flutter UI, Drift |
| `data` | Drift DB/DAOs, models, repo impls, datasources | widgets |
| `presentation` | pages, feature blocs/cubits | DB tables, raw Drift |

## Placement

- `main.dart` thin; routing → `lib/core/router/`
- Theme → `lib/core/theme/`; shared widgets → `lib/core/ui/`
- Drift → `lib/data/local/db/`; pages → `lib/presentation/<feature>/pages/`
- BLoCs → `lib/presentation/<feature>/bloc/`
- Pages use blocs — not use cases directly.
- Models → entities at repository boundary.
- One use case = one business action.

## Naming

- `presentation/device/` — not `devices`
- Log use cases → `domain/usecases/device_log/`
- Singular feature folders

## Drift migrations

1. Bump `schemaVersion` on schema change.
2. Add migration in DB setup; test with existing data when possible.
3. Run codegen (see `stack.md`).
4. Details: [docs/drift-db.md](../../../docs/drift-db.md)

## Standards

- Validate at use-case or form boundary.
- Drift queries only in DAOs/datasources/repos.
- No comments unless asked; prefer `const` where cheap.

Layout truth: [docs/AGENTS.md](../../../docs/AGENTS.md).
