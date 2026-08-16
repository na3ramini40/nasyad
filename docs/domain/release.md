# Release & install

Where: **client** (install/update UX and data preservation) + **server** N/A. Maintainer signing is owner-only.

Nasyad is local-first: data stays on the device. Updates install **over** the previous version and keep the local store — no uninstall step. Schema rules: [client-store.md](client-store.md).

## GitHub Release assets

Each tagged release (`vX.Y.Z`) ships:

| Platform | File | Install |
|----------|------|---------|
| Android ARM 32-bit | `nasyad-vX.Y.Z-armeabi-v7a.apk` | Open APK → Update (same app) |
| Android ARM 64-bit | `nasyad-vX.Y.Z-arm64-v8a.apk` | Open APK → Update (same app) — most phones |
| Android x86_64 | `nasyad-vX.Y.Z-x86_64.apk` | Emulators / x86 devices |
| Linux x64 | `nasyad-vX.Y.Z-linux-x64.tar.gz` | Extract over previous bundle or replace the folder |
| Windows x64 | `nasyad-vX.Y.Z-windows-x64.zip` | Extract over previous install folder |

CI builds with `flutter build apk --split-per-abi` so each asset contains only one CPU architecture (smaller downloads). In-app updates pick the matching ABI automatically. For manual install on a modern phone, use **arm64-v8a**.

macOS builds are not in CI yet; build locally with `flutter build macos --release`.

## Android: in-place updates

### Why you had to uninstall

Earlier releases were signed with a **debug key that changed on every CI run**. Android treats a different signature as a different app, so it blocked upgrades and forced uninstall + reinstall.

**Fix:** CI now signs release APKs with one stable release keystore (GitHub Actions secrets). After you install **one** release signed this way, later versions update in place.

### One-time migration (if you installed old APKs)

1. Export a backup from **Transfer** in the app (recommended).
2. Uninstall the old APK **once**.
3. Install the latest signed release from GitHub.
4. Import the backup if needed.

Future updates install over the existing app — no uninstall.

### “App isn’t secure” / Play Protect

Sideloaded APKs (not from Google Play) may show:

- “Install unknown apps” permission (one-time per browser/file manager)
- Play Protect “App not verified” → **Install anyway**

That is normal for direct APK installs. A release signing key reduces signature warnings but does **not** remove Play Protect for apps outside the Play Store.

## In-app updates (Android / Linux / Windows)

Nasyad can check [GitHub Releases](https://github.com/na3ramini40/nasyad/releases) for a newer version and install the platform asset.

- **Automatic:** After Home loads, the app checks in the background. If an update exists, a banner appears on Home.
- **Manual:** Preferences → About → **Check for updates**.

### Download behavior

- Downloads the **full release asset** for the current platform (and on Android, the matching CPU ABI) — binary delta patches are not used yet.
- Supports **resumable downloads** (HTTP Range) if a download is interrupted.
- Skips re-download when a cached file matches the expected size and SHA-256 checksum.

### Install behavior

| Platform | What happens |
|----------|----------------|
| Android | Opens the system package installer. Confirm the install (sideload). Requires release-signed APK for in-place upgrade. |
| Linux | Downloads and extracts to a staging folder, then runs a small updater script that waits for the app to quit, replaces files, and relaunches. |
| Windows | Same pattern with PowerShell: extract → updater waits for exit → copy → relaunch. |
| macOS | Not supported in-app yet (not in CI). |

Your local data stays on device through updates (same as manual installs). Export a backup before major version jumps if the changelog recommends it.

## Linux / Windows: manual in-place updates

Desktop builds use the same app id (`amini.apps.nasyad`) and store the local database in the platform app-data directory. To update:

1. Quit Nasyad.
2. Replace the old bundle/folder with the new release files (same path).
3. Launch — your data remains.

Optional: export a backup before major version jumps.

## Backward compatibility (data)

- **Patch/minor releases** preserve existing local data via store migrations ([client-store.md](client-store.md)).
- **Major releases** may require action if the changelog says so; export a backup first.
- Migration tests live in `client/test/` (e.g. app database migration tests).

When changing the database schema: bump `schemaVersion`, add upgrade steps, and extend migration tests.

## CI signing setup (maintainers only)

Release keystore access is **restricted**:

- **All contributors:** debug signing only (`flutter run`, local builds without `.env/android/` keystore).
- **You + CI:** release keystore via gitignored `.env/android/` or GitHub Actions secrets.

Local control plane (owner):

```text
.env/
  app.env                 # APP_APPLICATION_ID=amini.apps.nasyad, GITHUB_*, version, mode
  server.env              # Django secrets
  android/
    key.properties
    nasyad-release.jks
```

```bash
cp -a env.example .env
# edit .env/ then:
./tool/env_apply.sh
```

Or one-time keystore helpers: `./tool/setup_android_release_signing.sh` / `./tool/generate_android_keystore.sh` — place outputs under `.env/android/`.

Add these **GitHub repository secrets** (Settings → Secrets → Actions):

| Secret | Value |
|--------|-------|
| `ANDROID_KEYSTORE_BASE64` | `base64 -w0 .env/android/nasyad-release.jks` |
| `ANDROID_KEYSTORE_PASSWORD` | store password |
| `ANDROID_KEY_ALIAS` | `nasyad` |
| `ANDROID_KEY_PASSWORD` | key password |

Verify blocks committed keystores: `./tool/check_no_release_secrets.sh` (also via `./tool/ci_verify.sh`).

Tag builds **fail** if signing secrets are missing, so release APKs are never published with a one-off debug signature again.

Forks: keep `APP_APPLICATION_ID=com.example.nasyad` (or your own id) and leave `GITHUB_OWNER` / `GITHUB_REPO` empty so you never update-over or admin the official app.

Index: [../domain.md](../domain.md)

