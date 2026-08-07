# Layers & Drift

```text
presentation → domain ← data        (core supports all)
```

| Layer | Owns | Must not contain |
|-------|------|------------------|
| `core/` | router, theme, shared ui, calendar, version, utils | feature-only code |
| `domain/` | entities, repo contracts, services, use cases | Flutter UI, Drift |
| `data/` | Drift DB/DAOs (`local/db/`), models, repo impls, datasources | widgets |
| `presentation/` | `<feature>/{bloc,pages,widgets}` | raw Drift, direct use-case calls from widgets |

## Placement rules

- `main.dart` thin; routing in `core/router/`; theme tokens in `core/theme/`; shared widgets in `core/ui/`.
- Pages listen/build from blocs; blocs call use cases; one use case = one business action.
- Models map to entities at the repository boundary; Drift queries only in DAOs/datasources/repos.
- Validate at use-case or form boundary.

## Naming

Singular feature folders (`presentation/device/`, not `devices/`); log use cases in `domain/usecases/device_log/`.

## Drift migrations

1. Change schema → bump `schemaVersion` → add migration step in DB setup.
2. Preserve existing data — additive changes; copy-forward on renames (data-safety rule binds here).
3. Run codegen; add a migration test (open DB at old version, migrate, query) when data is at risk.
4. Store rules: `docs/domain/client-store.md`; layout: `docs/domain/client-layout.md`.
