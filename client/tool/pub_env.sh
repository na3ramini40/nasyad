#!/usr/bin/env bash
# Pub/Flutter mirror — local builds only.
# Tries Runflare first; falls back to devneeds.ir when unreachable.
# GitHub Actions uses default pub.dev hosts (no mirror env).
# See .cursor/rules/client/client.mdc

_runflare_pub="https://mirror-flutter.runflare.com"
_runflare_storage="https://mirror-gcs.runflare.com"
_fallback_pub="https://dart.devneeds.ir"
_fallback_storage="https://dart.devneeds.ir"

_mirror_reachable() {
  local base="${1%/}"
  local code
  code="$(
    curl -sS -o /dev/null -w "%{http_code}" --connect-timeout 5 \
      "${base}/api/packages/http" 2>/dev/null || echo "000"
  )"
  [[ "$code" == "200" ]]
}

if _mirror_reachable "$_runflare_pub"; then
  export PUB_HOSTED_URL="$_runflare_pub"
  export FLUTTER_STORAGE_BASE_URL="$_runflare_storage"
else
  export PUB_HOSTED_URL="$_fallback_pub"
  export FLUTTER_STORAGE_BASE_URL="$_fallback_storage"
fi
