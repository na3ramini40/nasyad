# Deep links

Infrastructure lives in `lib/core/deep_link/`. Platform wiring uses `app_links` and the `nasyad` custom URL scheme.

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
| `deep_link_handler.dart` | `app_links` stream → `GoRouter.go` |

## Platform setup

| Platform | Config |
|----------|--------|
| Android | `VIEW` intent filter with `android:scheme="nasyad"` in `AndroidManifest.xml` |
| iOS | `CFBundleURLTypes` / `nasyad` scheme in `Info.plist` |
| macOS | `CFBundleURLTypes` / `nasyad` scheme in `Info.plist` |

`DeepLinkHandler.install()` runs from `MyApp` and subscribes to `AppLinks.uriLinkStream` (cold + warm start). Navigation is deferred one frame so `MaterialApp.router` is mounted.

## Add a new link

1. Add a route in `lib/core/router/app_router.dart` if missing.
2. Add a `DeepLinkTarget` subclass in `deep_link_target.dart`.
3. Extend `DeepLinkParser.parse` switch for the new path segments.
4. Extend `DeepLinkMapper.toLocation` for the matching go_router path.
5. Add parser + mapper cases in `test/core/deep_link_test.dart`.

Keep splash and other boot-only routes out of external deep links unless product requires them.

## Manual test

**Android**

```bash
adb shell am start -a android.intent.action.VIEW -d "nasyad:///devices"
```

**iOS simulator**

```bash
xcrun simctl openurl booted "nasyad:///devices"
```

**macOS** — open `nasyad:///devices` from Terminal or a browser address bar while the app is running.
