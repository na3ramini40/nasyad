#!/usr/bin/env bash
# Fail if Android release signing material is tracked in git.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

tracked="$(git ls-files -- \
  'android/key.properties' \
  'android/keystore' \
  'android/keystore/*' \
  '*.jks' \
  '*.keystore' \
  2>/dev/null || true)"

if [[ -n "$tracked" ]]; then
  echo "Release signing material must NOT be in git:" >&2
  echo "$tracked" >&2
  echo "Remove from index; keep keystore local or in GitHub Actions secrets only." >&2
  exit 1
fi

# Block accidental commit of common secret filenames in android/
for path in android/key.properties android/keystore/nasyad-release.jks; do
  if git check-ignore -q "$path" 2>/dev/null; then
    continue
  fi
  if [[ -f "$path" ]] && git ls-files --error-unmatch "$path" &>/dev/null; then
    echo "Untracked signing file is staged or committed: $path" >&2
    exit 1
  fi
done

echo "check_no_release_secrets OK"
