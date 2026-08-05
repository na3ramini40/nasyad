# Bump release

Version + changelog for release-bound work. Read [`.cursor/rules/github-tag-release.mdc`](../rules/github-tag-release.mdc).

## 1. Choose bump

| Kind | Use when |
|------|----------|
| patch | Bug fixes; refactors/CI; copy/a11y polish; non-breaking Drift migrations |
| minor | New user-facing capability, screen, flow, or export option |
| major | Breaking backup/import, removed feature, data-model break users must act on |

When in doubt: **minor** if end users notice new capability; else **patch**. User override wins.

## 2. Apply

```bash
dart run tool/bump_version.dart <major|minor|patch>
```

Prepend `ChangelogEntry` in `lib/core/version/app_changelog.dart`:

```dart
ChangelogEntry(
  version: 'X.Y.Z',
  en: ['End-user bullet…'],
  fa: ['همان معنی به فارسی…'],
),
```

- Newest entry first in the list.
- Both `en` and `fa` need at least one bullet (`hasNotesForAllLanguages`).
- End-user tone — not implementation detail.

## 3. Verify

```bash
./tool/ci_verify.sh
```

Tag only after green CI on `main`:

```bash
./tool/ci_verify.sh --tag vX.Y.Z
git tag vX.Y.Z && git push origin vX.Y.Z
```

Tell stakeholder: bump kind, why, new version, whether tag was pushed.
