# Installing and updating Nasyad

Nasyad is local-first: your data stays on the device. Updates should install **over** the previous version and keep your database — no uninstall step.

## GitHub Release assets

Each tagged release (`vX.Y.Z`) ships:

| Platform | File | Install |
|----------|------|---------|
| Android | `nasyad-vX.Y.Z.apk` | Open APK → Update (same app) |
| Linux x64 | `nasyad-vX.Y.Z-linux-x64.tar.gz` | Extract over previous bundle or replace the folder |
| Windows x64 | `nasyad-vX.Y.Z-windows-x64.zip` | Extract over previous install folder |

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

- Downloads the **full release asset** (APK, tar.gz, or zip) — binary delta patches are not used yet.
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

Desktop builds use the same app id (`amini.apps.nasyad`) and store the Drift database in the platform app-data directory. To update:

1. Quit Nasyad.
2. Replace the old bundle/folder with the new release files (same path).
3. Launch — your data remains.

Optional: export a backup before major version jumps.

## Backward compatibility (data)

- **Patch/minor releases** preserve existing local data via Drift migrations (`lib/data/local/db/app_database.dart`).
- **Major releases** may require action if the changelog says so; export a backup first.
- Migration tests live in `test/data/app_database_migration_test.dart`.

When changing the database schema: bump `schemaVersion`, add `onUpgrade` steps, and extend migration tests.

## CI signing setup (maintainers only)

Release keystore access is **restricted**:

- **All contributors:** debug signing only (`flutter run`, local builds without `key.properties`).
- **You + CI:** release keystore via local gitignored files or GitHub Actions secrets.

One-time keystore (run locally — never commit output):

```bash
./tool/setup_android_release_signing.sh   # keystore + key.properties + GitHub secrets
```

Or manually: `./tool/generate_android_keystore.sh` then add secrets below.

Add these **GitHub repository secrets** (Settings → Secrets → Actions). Use a **Environment** named `release` with protection rules if you want approval gates — only you need access:

| Secret | Value |
|--------|-------|
| `ANDROID_KEYSTORE_BASE64` | `base64 -w0 android/keystore/nasyad-release.jks` |
| `ANDROID_KEYSTORE_PASSWORD` | store password |
| `ANDROID_KEY_ALIAS` | `nasyad` |
| `ANDROID_KEY_PASSWORD` | key password |

Local release builds (maintainer only): copy `android/key.properties.example` → `android/key.properties` and fill passwords. File stays gitignored.

Verify blocks committed keystores: `./tool/check_no_release_secrets.sh`.

Tag builds **fail** if signing secrets are missing, so release APKs are never published with a one-off debug signature again.
