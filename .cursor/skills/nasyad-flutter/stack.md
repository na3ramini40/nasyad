# Stack (active only)

From `pubspec.yaml` — use these by default:

| Concern | Package |
|---------|---------|
| Routing | `go_router` |
| Local DB | `drift_flutter` + `drift_dev` |
| State | `flutter_bloc` |
| Models | `equatable`, `json_annotation` |
| Transfer | `share_plus`, `path_provider`, `file_selector` |
| Prefs | `shared_preferences` |
| Calendar | `shamsi_date` |
| Codegen | `build_runner` |
| i18n | `flutter_localizations` + `intl` (`en`, `fa`) |

**Do not assume** `get_it`, `injectable`, `freezed`, or network clients.

**Package choice:** prefer `pub.dev` over custom reimplementations when the behavior is general-purpose — see `.cursor/rules/nasyad-scope.mdc` (Engineering boundaries).

## Codegen

After Drift schema/DAO/annotation changes:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Never hand-edit `*.g.dart`.

## Version bump

Release-bound work: `/bump-release` command + `rules/github-tag-release.mdc`.

## Pub mirror (Runflare — local only)

**Locally**, use Runflare — not `pub-azs.ir`. GitHub Actions uses default `pub.dev` hosts.

```bash
source tool/pub_env.sh   # sets PUB_HOSTED_URL + FLUTTER_STORAGE_BASE_URL
flutter pub get
```

| Variable | URL |
|----------|-----|
| `PUB_HOSTED_URL` | `https://mirror-flutter.runflare.com` |
| `FLUTTER_STORAGE_BASE_URL` | `https://mirror-gcs.runflare.com` |

`./tool/ci_verify.sh` sources this for local verify. Rule: `.cursor/rules/pub-mirror.mdc`.

## Android signing

- **Debug:** all contributors — default when `android/key.properties` is absent.
- **Release:** maintainer + CI secrets only — see `docs/release-install.md`, rule `.cursor/rules/android-release-signing.mdc`.
