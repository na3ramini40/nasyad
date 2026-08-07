# Deep links

`lib/core/deep_link/` + `app_links` package; custom scheme `nasyad`.

Canonical URI: `nasyad:///<go_router-path>[?query]` — e.g. `nasyad:///devices`, `nasyad:///device/{id}/log?kind=usage`. Host-only form (`nasyad://devices`) also resolves.

| File | Role |
|------|------|
| `deep_link_target.dart` | sealed navigation targets |
| `deep_link_parser.dart` | `Uri` → `DeepLinkTarget?` |
| `deep_link_mapper.dart` | target → go_router location |
| `deep_link_handler.dart` | `app_links` stream → `GoRouter.go` (cold + warm start, deferred one frame) |

Platform config: `VIEW` intent filter (Android manifest), `CFBundleURLTypes` (iOS/macOS plists).

## Adding a link

1. Route exists in `core/router/app_router.dart`.
2. New `DeepLinkTarget` subclass → parser case → mapper case.
3. Parser + mapper tests in `test/core/deep_link_test.dart`.
4. Keep boot-only routes (splash) out of external links.

Manual check: `adb shell am start -a android.intent.action.VIEW -d "nasyad:///devices"`.
