# Nasyad

Local-first maintenance tracker for devices, assets, and recurring follow-ups. Data stays on device — no cloud sync in this phase.

## Run locally

```bash
flutter pub get
flutter run
```

Tests and analysis:

```bash
flutter analyze
flutter test
```

After Drift / codegen changes:

```bash
dart run build_runner build
```

More project rules: [`docs/AGENTS.md`](docs/AGENTS.md).

## Local CI (before a PR)

Run the same checks as GitHub **Verify** before opening or updating a PR:

```bash
./tool/ci_verify.sh
```

Agents and contributors must not create a PR until this script passes.

## CI / CD (GitHub Actions)

Workflow: [`.github/workflows/ci.yml`](.github/workflows/ci.yml). Flutter pinned to **3.35.6**.

| Job | What | When |
|-----|------|------|
| **Verify** | version consistency, format, Drift codegen freshness, `analyze`, `test` | Every push/PR/tag + manual run |
| **Build APK** | release APK artifact named from `pubspec.yaml` version (30 days) | Auto on `main`/`master` & `v*` tags; manual via **Run workflow** |
| **GitHub Release** | attaches `nasyad-vX.Y.Z.apk` | Auto on tags like `v1.1.0` (must match app version) |

### Versioning

Keep these three in sync (CI enforces it):

1. `pubspec.yaml` `version:` (e.g. `1.1.0+2`)
2. `lib/core/version/app_version.dart` (generated)
3. Newest entry in `lib/core/version/app_changelog.dart` (en + fa notes)

```bash
dart run tool/bump_version.dart minor   # or major | patch
# then edit changelog notes for the new version
dart run tool/check_version.dart
```

Release tags must match the name: `git tag v1.1.0` when the app is `1.1.0+…`.

### How to use

1. Open a PR — **Verify** runs automatically (no APK yet).
2. To build an APK from a PR branch: **Actions → CI → Run workflow** → pick the branch.
3. Merge to `main`/`master` — Verify + APK build run automatically.
4. Tag a release: `git tag v1.1.0 && git push origin v1.1.0` — builds APK and creates a GitHub Release.

### Notes

- Android release currently uses the **debug keystore** (see `android/app/build.gradle.kts`). Fine for sideloading; Play Store needs a real signing key.
- Only APK is built for now; other platforms can be added later.
