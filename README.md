# Nasyad

Local-first maintenance tracker for devices, assets, and recurring follow-ups. Data stays on device — no cloud sync in this phase.

## Run locally

```bash
source tool/pub_env.sh   # Runflare mirror — local only
flutter pub get
flutter run
```

Local pub packages use the **Runflare** mirror via `tool/pub_env.sh` (see `.cursor/rules/pub-mirror.mdc`). GitHub CI uses default `pub.dev`. Do not use `pub-azs.ir` for this repo.

Tests and analysis:

```bash
source tool/pub_env.sh
flutter analyze
flutter test
```

After Drift / codegen changes:

```bash
source tool/pub_env.sh
dart run build_runner build
```

Agent entry: [`.cursor/AGENTS.md`](.cursor/AGENTS.md). Engineering rules: [`docs/AGENTS.md`](docs/AGENTS.md).

## Local CI (before a PR)

See [`.cursor/commands/verify-ci.md`](.cursor/commands/verify-ci.md) and [`.cursor/rules/ci-before-pr.mdc`](.cursor/rules/ci-before-pr.mdc). Quick run:

```bash
./tool/ci_verify.sh
```

## CI / CD (GitHub Actions)

Workflow: [`.github/workflows/ci.yml`](.github/workflows/ci.yml). Flutter pinned to **3.35.6**.

| Job | What | When |
|-----|------|------|
| **Verify** | version consistency, format, Drift codegen freshness, `analyze`, `test` | Every push/PR/tag + manual run |
| **Build APK** | release APK artifact named from `pubspec.yaml` version (30 days) | Auto on `main`/`master` & `v*` tags; manual via **Run workflow** |
| **Build Linux** | `nasyad-vX.Y.Z-linux-x64.tar.gz` | Same triggers as APK |
| **Build Windows** | `nasyad-vX.Y.Z-windows-x64.zip` | Same triggers as APK |
| **GitHub Release** | APK + Linux + Windows assets | Auto on tags like `v1.1.0` (must match app version) |

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

- **Install & update:** [docs/release-install.md](docs/release-install.md) — sideload signing, in-place upgrades, desktop updates, data migrations.
- Release APKs require Android signing secrets in GitHub Actions (see doc). Without them, tag builds fail; main-branch builds use debug signing for artifacts only.
- macOS is not built in CI yet; use `flutter build macos --release` locally.
