#!/usr/bin/env bash
# Mirrors the GitHub Actions "Verify" job in .github/workflows/ci.yml.
# Run before opening or updating a pull request.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

# Runflare mirror (see .cursor/rules/pub-mirror.mdc)
# shellcheck source=pub_env.sh
source "$ROOT/tool/pub_env.sh"

TAG=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --tag)
      TAG="${2:-}"
      shift 2
      ;;
    -h|--help)
      echo "Usage: tool/ci_verify.sh [--tag vX.Y.Z]"
      echo "Runs the same checks as CI Verify (pub get, version, format, codegen, analyze, test)."
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      echo "Usage: tool/ci_verify.sh [--tag vX.Y.Z]" >&2
      exit 64
      ;;
  esac
done

step() {
  echo
  echo "==> $*"
}

fail() {
  echo
  echo "ci_verify FAILED: $*" >&2
  exit 1
}

step "check no release signing secrets in git"
"$ROOT/tool/check_no_release_secrets.sh" || fail "release signing material in git"

step "flutter pub get"
flutter pub get || fail "flutter pub get"

step "check version consistency"
if [[ -n "$TAG" ]]; then
  dart run tool/check_version.dart --tag "$TAG" || fail "version check (tag $TAG)"
else
  dart run tool/check_version.dart || fail "version check"
fi

step "dart format"
dart format --output=none --set-exit-if-changed . || fail "dart format (run: dart format .)"

step "build_runner (Drift codegen)"
dart run build_runner build || fail "build_runner"

step "generated code is committed"
if ! git diff --exit-code -- lib/; then
  fail "lib/ changed after build_runner — commit generated Drift files"
fi

step "flutter analyze"
flutter analyze || fail "flutter analyze"

step "flutter test"
flutter test || fail "flutter test"

echo
echo "ci_verify OK — safe to open or update a PR."
