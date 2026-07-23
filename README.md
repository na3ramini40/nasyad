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

## CI / CD (GitHub Actions)

Workflow: [`.github/workflows/ci.yml`](.github/workflows/ci.yml). Flutter pinned to **3.35.6**.

| Job | What | When |
|-----|------|------|
| **Verify** | format, Drift codegen freshness, `analyze`, `test` | Every push/PR/tag + manual run |
| **Build APK** | release APK artifact (30 days) | Auto on `main`/`master` & `v*` tags; manual via **Run workflow** |
| **GitHub Release** | attaches `nasyad-<tag>.apk` | Auto on tags like `v1.0.0` |

### How to use

1. Open a PR — **Verify** runs automatically (no APK yet).
2. To build an APK from a PR branch: **Actions → CI → Run workflow** → pick the branch.
3. Merge to `main`/`master` — Verify + APK build run automatically.
4. Tag a release: `git tag v1.0.0 && git push origin v1.0.0` — builds APK and creates a GitHub Release.

### Notes

- Android release currently uses the **debug keystore** (see `android/app/build.gradle.kts`). Fine for sideloading; Play Store needs a real signing key.
- Only APK is built for now; other platforms can be added later.
