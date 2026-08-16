#!/usr/bin/env bash
# Cross-OS client↔server sync integration: Device A pushes, Device B pulls, catalogs match.
# Requires server/.venv (created by ./tool/ci_verify.sh / ./tool/dev.sh --setup).
# Uses only Python + Flutter — no curl, no Android/iOS tooling.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SERVER="$ROOT/server"
CLIENT="$ROOT/client"

if [[ -x "$SERVER/.venv/bin/python" ]]; then
  PYTHON="$SERVER/.venv/bin/python"
elif [[ -x "$SERVER/.venv/Scripts/python.exe" ]]; then
  PYTHON="$SERVER/.venv/Scripts/python.exe"
else
  echo "sync_integration_test: missing server/.venv — run ./tool/dev.sh --setup first" >&2
  exit 1
fi

# shellcheck source=/dev/null
source "$CLIENT/tool/pub_env.sh"

TMP_DB="$(mktemp "${TMPDIR:-/tmp}/nasyad-sync-it-XXXXXX.sqlite3")"
LOG_FILE="$(mktemp "${TMPDIR:-/tmp}/nasyad-sync-it-XXXXXX.log")"
SERVER_PID=""

cleanup() {
  if [[ -n "${SERVER_PID}" ]] && kill -0 "$SERVER_PID" 2>/dev/null; then
    kill "$SERVER_PID" 2>/dev/null || true
    wait "$SERVER_PID" 2>/dev/null || true
  fi
  rm -f "$TMP_DB" "$LOG_FILE" "${TMP_DB}-journal" "${TMP_DB}-wal" "${TMP_DB}-shm"
}
trap cleanup EXIT

PORT="$("$PYTHON" - <<'PY'
import socket
s = socket.socket()
s.bind(("127.0.0.1", 0))
print(s.getsockname()[1])
s.close()
PY
)"

export NASYAD_TEST_DB="$TMP_DB"
export DJANGO_DEBUG=true
cd "$SERVER"
"$PYTHON" manage.py migrate --run-syncdb -v0
"$PYTHON" manage.py runserver "127.0.0.1:${PORT}" --noreload >"$LOG_FILE" 2>&1 &
SERVER_PID=$!

"$PYTHON" - <<PY
import sys, time, urllib.request
url = "http://127.0.0.1:${PORT}/api/health/"
for _ in range(80):
    try:
        with urllib.request.urlopen(url, timeout=1) as r:
            if r.status == 200:
                sys.exit(0)
    except Exception:
        time.sleep(0.25)
print("sync_integration_test: server did not become healthy", file=sys.stderr)
sys.exit(1)
PY

echo "==> sync integration (server http://127.0.0.1:${PORT})"
cd "$CLIENT"
flutter test test/integration/two_device_remote_sync_test.dart \
  --dart-define=SYNC_IT_BASE_URL="http://127.0.0.1:${PORT}"

echo "sync_integration_test OK"
