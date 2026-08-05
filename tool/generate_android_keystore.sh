#!/usr/bin/env bash
# One-time: create the release keystore used for all GitHub Release APKs.
# Keep the .jks private; add it to GitHub Actions secrets (see docs/release-install.md).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KEYSTORE_DIR="$ROOT/android/keystore"
KEYSTORE="$KEYSTORE_DIR/nasyad-release.jks"
ALIAS="nasyad"

if [[ -f "$KEYSTORE" ]]; then
  echo "Keystore already exists: $KEYSTORE" >&2
  echo "Delete it first if you intend to regenerate." >&2
  exit 1
fi

mkdir -p "$KEYSTORE_DIR"

echo "Creating release keystore at $KEYSTORE"
echo "You will be prompted for store and key passwords — save them securely."
echo

keytool -genkeypair \
  -v \
  -keystore "$KEYSTORE" \
  -alias "$ALIAS" \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -dname "CN=Nasyad, OU=Release, O=Nasyad"

echo
echo "SECURITY: The release keystore is gitignored. Never commit it."
echo "  - Contributors: use debug builds only (no key.properties needed)."
echo "  - Release APKs: GitHub Actions secrets (maintainer) — docs/release-install.md"
echo "  Or run: ./tool/setup_android_release_signing.sh (keystore + GitHub secrets)"
echo
echo "Next steps (maintainer only):"
echo "  1. Copy android/key.properties.example → android/key.properties and fill passwords."
echo "  2. Add GitHub secrets (see docs/release-install.md)."
echo "  3. Re-tag or run CI on main — future APKs upgrade in place over the same install."
