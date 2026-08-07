# Stack (active only)

From `client/pubspec.yaml` — default to these:

| Concern | Package |
|---------|---------|
| Routing | `go_router` |
| Local DB | `drift_flutter` + `drift_dev` (codegen via `build_runner`) |
| State | `flutter_bloc` |
| Models | `equatable`, `json_annotation` |
| i18n | `flutter_localizations` + `intl` (en, fa) |
| Prefs | `shared_preferences` |
| App lock | `local_auth`, `flutter_secure_storage` (secrets; not synced) |
| Calendar | `shamsi_date` |
| Transfer | `share_plus`, `path_provider`, `file_selector` |
| Updates/network | `http`, `crypto` (GitHub release checks only) |
| Notifications | `firebase_core`, `firebase_messaging`, `flutter_local_notifications` (skipped on Linux) |
| Deep links | `app_links` |
| Maps (place) | `flutter_map`, `geolocator`, `latlong2` |

**Not in this repo:** `get_it`, `injectable`, `freezed`, `mocktail`, dio/retrofit — do not assume them; adding one requires a root `AGENTS.md` update.

**Package choice:** prefer a maintained pub.dev package over reimplementing general-purpose behavior.
