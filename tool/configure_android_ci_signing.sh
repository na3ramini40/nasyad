#!/usr/bin/env bash
# Configure Android release signing for CI. Never prints secrets.
# Exit 0: release signing ready, or debug signing fallback allowed.
# Exit 1: release signing required but invalid (tag builds).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KEYSTORE="$ROOT/android/keystore/nasyad-release.jks"
KEY_PROPERTIES="$ROOT/android/key.properties"
IS_TAG="${CI_ANDROID_SIGNING_REQUIRED:-0}"

cleanup_signing() {
  rm -f "$KEY_PROPERTIES"
  rm -f "$KEYSTORE"
}

if [[ -z "${ANDROID_KEYSTORE_BASE64:-}" ]]; then
  if [[ "$IS_TAG" == "1" ]]; then
    echo "::error::Release tags require Android signing secrets. See docs/release-install.md" >&2
    exit 1
  fi
  echo "No release keystore secrets — building with debug signing (not for sideload upgrades)."
  cleanup_signing
  exit 0
fi

mkdir -p "$(dirname "$KEYSTORE")"
# Strip whitespace/newlines GitHub Secrets may introduce when pasted.
tr -d '[:space:]' <<< "$ANDROID_KEYSTORE_BASE64" | base64 --decode > "$KEYSTORE"

if [[ ! -s "$KEYSTORE" ]]; then
  echo "::error::Decoded keystore is empty. Re-run ./tool/setup_android_release_signing.sh" >&2
  cleanup_signing
  [[ "$IS_TAG" == "1" ]] && exit 1
  echo "Falling back to debug signing for this branch build."
  exit 0
fi

printf 'storePassword=%s\nkeyPassword=%s\nkeyAlias=%s\nstoreFile=keystore/nasyad-release.jks\n' \
  "$ANDROID_KEYSTORE_PASSWORD" \
  "$ANDROID_KEY_PASSWORD" \
  "$ANDROID_KEY_ALIAS" \
  > "$KEY_PROPERTIES"

if ! keytool -list \
  -keystore "$KEYSTORE" \
  -storepass "$ANDROID_KEYSTORE_PASSWORD" \
  -alias "$ANDROID_KEY_ALIAS" \
  >/dev/null 2>&1; then
  echo "::error::Release keystore secrets do not match the decoded .jks file." >&2
  echo "::error::Re-run ./tool/setup_android_release_signing.sh to regenerate and upload secrets." >&2
  cleanup_signing
  if [[ "$IS_TAG" == "1" ]]; then
    exit 1
  fi
  echo "Falling back to debug signing for this branch build."
  exit 0
fi

echo "Release signing configured."
