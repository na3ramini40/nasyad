#!/usr/bin/env bash
# One-time maintainer setup: release keystore + GitHub Actions secrets + local key.properties.
# Never commits secrets. Requires: keytool, gh (authenticated), repo admin for secrets.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KEYSTORE_DIR="$ROOT/android/keystore"
KEYSTORE="$KEYSTORE_DIR/nasyad-release.jks"
KEY_PROPERTIES="$ROOT/android/key.properties"
ALIAS="nasyad"

if [[ -f "$KEYSTORE" ]]; then
  echo "Keystore already exists: $KEYSTORE" >&2
  echo "Delete it first to regenerate, or run gh secret set manually." >&2
  exit 1
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "gh CLI required. Install and run: gh auth login" >&2
  exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "gh not authenticated. Run: gh auth login" >&2
  exit 1
fi

mkdir -p "$KEYSTORE_DIR"
STORE_PASS="$(openssl rand -base64 24 | tr -d '/+=' | head -c 24)"
KEY_PASS="$STORE_PASS"

echo "==> Generating release keystore (local, gitignored)"
keytool -genkeypair \
  -v \
  -keystore "$KEYSTORE" \
  -alias "$ALIAS" \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -storepass "$STORE_PASS" \
  -keypass "$KEY_PASS" \
  -dname "CN=Nasyad, OU=Release, O=Nasyad"

echo "==> Writing android/key.properties (gitignored)"
cat > "$KEY_PROPERTIES" <<EOF
storePassword=$STORE_PASS
keyPassword=$KEY_PASS
keyAlias=$ALIAS
storeFile=keystore/nasyad-release.jks
EOF
chmod 600 "$KEY_PROPERTIES" "$KEYSTORE"

echo "==> Uploading GitHub Actions secrets"
BASE64_KEYSTORE="$(base64 -w0 "$KEYSTORE")"
gh secret set ANDROID_KEYSTORE_BASE64 --body "$BASE64_KEYSTORE"
gh secret set ANDROID_KEYSTORE_PASSWORD --body "$STORE_PASS"
gh secret set ANDROID_KEY_ALIAS --body "$ALIAS"
gh secret set ANDROID_KEY_PASSWORD --body "$KEY_PASS"

echo "==> Verifying secrets registered"
gh secret list | grep -E '^ANDROID_' || true

echo
echo "Setup complete."
echo "  - Local: android/key.properties + android/keystore/nasyad-release.jks (gitignored)"
echo "  - CI: ANDROID_KEYSTORE_* secrets set on $(gh repo view --json nameWithOwner -q .nameWithOwner)"
echo "  - Passwords are NOT printed; retrieve from GitHub Secrets UI if needed."
echo "  - Next: merge these changes, tag vX.Y.Z — CI will sign release APKs for in-place upgrades."
