# Release

Version bump + changelog + optional tag. Full policy: `.cursor/rules/shared/release.mdc` (agent decides the bump kind from scope).

1. `cd client && dart run tool/bump_version.dart <major|minor|patch>`
2. Prepend `ChangelogEntry` in `client/lib/core/version/app_changelog.dart` — newest first, en + fa bullets, **client-only** end-user tone.
3. Add `docs/domain/releases/vX.Y.Z.md` with **Client** + **Server** sections (GitHub Release body; CI `body_path`).
4. `/verify` → green.
5. Tag only when the user wants a release, after green CI on `main`:

```bash
./tool/ci_verify.sh --tag vX.Y.Z && git tag vX.Y.Z && git push origin vX.Y.Z
```

Report one line: bump kind, why, new version, tag pushed or not.
