# Client layout (this repo)

Where: **client** (Flutter tree under `client/lib/`). Other client stacks may use different folders; they must still map to the same domain surfaces and layers of responsibility.

## Layers

| Layer | Owns | Must not |
|-------|------|----------|
| `core/` | router, theme, shared ui, calendar, version, utils | feature-only code |
| `domain/` | entities, repo contracts, services, use cases | Flutter UI, local-DB types |
| `data/` | local DB/DAOs, models, repo impls, datasources | widgets |
| `presentation/` | `<feature>/{bloc,pages,widgets}` | raw DB access; use cases called from widgets |

Flow: `presentation → domain ← data` (`core` supports all).

## Placement rules

- `main.dart` thin; routing in `core/router/`; theme in `core/theme/`; shared widgets in `core/ui/`.
- Pages listen/build from blocs; blocs call use cases; one use case = one business action.
- Models map to entities at the repository boundary; DB queries only in data layer.
- Singular feature folders (`presentation/device/`, not `devices/`); log use cases under `usecases/device_log/`.
- No `injection/` / `get_it` / `injectable` in this repo — wire in `app_services` / constructors unless `AGENTS.md` is updated.

Local store details: [client-store.md](client-store.md). Surfaces: [structure.md](structure.md). Index: [../domain.md](../domain.md)
