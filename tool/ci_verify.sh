#!/usr/bin/env bash
# Monorepo verify — client + server. Must exit 0 before any PR claim.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "==> env control plane (optional apply if .env/ present)"
if [[ -d "$ROOT/.env" && -f "$ROOT/.env/app.env" ]]; then
  "$ROOT/tool/env_apply.sh"
else
  echo "    no .env/ — using committed version + example Android defaults"
fi

echo "==> client verify"
"$ROOT/client/tool/ci_verify.sh" "$@"

echo "==> server verify"
if [[ ! -d "$ROOT/server/.venv" ]]; then
  echo "Creating server/.venv for verify…"
  python3 -m venv "$ROOT/server/.venv"
  # shellcheck disable=SC1091
  source "$ROOT/server/.venv/bin/activate"
  pip install -q -r "$ROOT/server/requirements.txt"
else
  # shellcheck disable=SC1091
  source "$ROOT/server/.venv/bin/activate"
fi
"$ROOT/server/tool/check.sh"

echo
echo "ci_verify OK — client + server green; safe to open or update a PR."
