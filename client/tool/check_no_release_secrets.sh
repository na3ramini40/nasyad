#!/usr/bin/env bash
# Fail if Android release signing material or `.env/` secrets are tracked in git.
set -euo pipefail

CLIENT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROOT="$(cd "$CLIENT/.." && pwd)"
cd "$ROOT"

tracked="$(git ls-files -- \
  '.env' \
  '.env/*' \
  'client/android/key.properties' \
  'client/android/nasyad.local.properties' \
  'client/android/keystore' \
  'client/android/keystore/*' \
  'android/key.properties' \
  'android/keystore' \
  'android/keystore/*' \
  '*.jks' \
  '*.keystore' \
  2>/dev/null || true)"

if [[ -n "$tracked" ]]; then
  echo "Release signing / env secrets must NOT be in git:" >&2
  echo "$tracked" >&2
  echo "Remove from index; keep under .env/ (gitignored) or GitHub Actions secrets." >&2
  exit 1
fi

for path in \
  client/android/key.properties \
  client/android/nasyad.local.properties \
  client/android/keystore/nasyad-release.jks \
  .env/android/key.properties \
  .env/android/nasyad-release.jks
do
  if [[ -f "$path" ]] && git ls-files --error-unmatch "$path" &>/dev/null; then
    echo "Secret file is tracked: $path" >&2
    exit 1
  fi
done

echo "check_no_release_secrets OK"
