# Deep links

Infrastructure lives in `lib/core/deep_link/`. No platform intent filters yet — parser + mapper only.

## Canonical URI

```text
nasyad:///<go_router-path>[?query]
```

Examples: `nasyad:///`, `nasyad:///devices`, `nasyad:///device/{id}/log?kind=usage`.

Host-only form also works: `nasyad://devices` → `/devices`.

## Layers

| File | Role |
|------|------|
| `deep_link_constants.dart` | Scheme + format docs |
| `deep_link_target.dart` | Sealed navigation targets |
| `deep_link_parser.dart` | `Uri` → `DeepLinkTarget?` |
| `deep_link_mapper.dart` | `DeepLinkTarget` → location string |
| `deep_link_resolver.dart` | Facade for parse + map |
| `deep_link_handler.dart` | Stub; future platform stream → `GoRouter.go` |

## Add a new link

1. Add a route in `lib/core/router/app_router.dart` if missing.
2. Add a `DeepLinkTarget` subclass in `deep_link_target.dart`.
3. Extend `DeepLinkParser.parse` switch for the new path segments.
4. Extend `DeepLinkMapper.toLocation` for the matching go_router path.
5. Add parser + mapper cases in `test/core/deep_link_test.dart`.
6. When ready to handle live links: wire `app_links` (or go_router deep link API) inside `DeepLinkHandler.install`, call `handleUri` on incoming URIs, and add platform intent filters / entitlements.

Keep splash and other boot-only routes out of external deep links unless product requires them.
