#!/usr/bin/env bash
# One command to run Nasyad locally (server + Flutter client).
#
# Config: repo-root `.env/` (from `env.example/`) — single control plane.
#
# Usage:
#   ./tool/dev.sh                 # server + client
#   ./tool/dev.sh --setup         # bootstrap deps only (no run)
#   ./tool/dev.sh --server-only   # API only
#   ./tool/dev.sh --client-only   # Flutter only (offline/local-first)
#   ./tool/dev.sh --docker        # server in Docker + Flutter on host
#   ./tool/dev.sh -- -d linux     # extra args passed to flutter run
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLIENT="$ROOT/client"
SERVER="$ROOT/server"
COMPOSE_FILE="$ROOT/docker-compose.yml"
ENV_DIR="$ROOT/.env"
EXAMPLE_DIR="$ROOT/env.example"

MODE="all"
USE_DOCKER=0
SETUP_ONLY=0
FLUTTER_ARGS=()

usage() {
  sed -n '2,14p' "$0" | sed 's/^# \?//'
  exit "${1:-0}"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help) usage 0 ;;
    --setup) SETUP_ONLY=1; shift ;;
    --server-only) MODE="server"; shift ;;
    --client-only) MODE="client"; shift ;;
    --docker) USE_DOCKER=1; shift ;;
    --) shift; FLUTTER_ARGS=("$@"); break ;;
    *) FLUTTER_ARGS+=("$1"); shift ;;
  esac
done

SERVER_PID=""
COMPOSE_STARTED=0

log() { echo "==> $*"; }

ensure_env_dir() {
  if [[ -d "$ENV_DIR" && -f "$ENV_DIR/app.env" ]]; then
    return 0
  fi
  # Migrate legacy root .env file or server/.env
  if [[ -f "$ROOT/.env" && ! -d "$ROOT/.env" ]]; then
    log "legacy root .env file found — run tool/env_apply after converting to .env/"
  fi
  if [[ ! -d "$EXAMPLE_DIR" ]]; then
    echo "Missing $EXAMPLE_DIR" >&2
    exit 1
  fi
  mkdir -p "$ENV_DIR/android"
  cp -a "$EXAMPLE_DIR/app.env" "$ENV_DIR/app.env"
  cp -a "$EXAMPLE_DIR/server.env" "$ENV_DIR/server.env"
  if [[ -f "$EXAMPLE_DIR/android/key.properties.example" ]]; then
    cp -a "$EXAMPLE_DIR/android/key.properties.example" \
      "$ENV_DIR/android/key.properties.example"
  fi
  if [[ -f "$SERVER/.env" ]]; then
    grep -E '^(DJANGO_|CORS_|SMS_|DATABASE_|EMAIL_)' "$SERVER/.env" \
      >>"$ENV_DIR/server.env" || true
    log "merged server/.env keys into .env/server.env"
  fi
  log "created .env/ from env.example/ — edit under .env/"
}

load_env_file() {
  local file="$1"
  [[ -f "$file" ]] || return 0
  set -a
  # shellcheck disable=SC1090
  source "$file"
  set +a
}

load_env() {
  ensure_env_dir
  "$ROOT/tool/env_apply.sh"
  load_env_file "$ENV_DIR/app.env"
  load_env_file "$ENV_DIR/server.env"
}

api_base_url() {
  echo "${API_BASE_URL:-http://127.0.0.1:8000}"
}

wait_for_health() {
  local base health
  base="$(api_base_url)"
  base="${base%/}"
  health="$base/api/health/"
  log "waiting for server at $health"
  for _ in $(seq 1 60); do
    if command -v curl >/dev/null 2>&1 && curl -sf "$health" >/dev/null 2>&1; then
      log "server is up"
      return 0
    fi
    if API_HEALTH_URL="$health" python3 - <<'PY' 2>/dev/null
import os, urllib.request
urllib.request.urlopen(os.environ["API_HEALTH_URL"], timeout=1)
PY
    then
      log "server is up"
      return 0
    fi
    sleep 0.5
  done
  echo "Server did not become healthy in time." >&2
  return 1
}

cleanup() {
  if [[ -n "$SERVER_PID" ]]; then
    kill "$SERVER_PID" 2>/dev/null || true
    wait "$SERVER_PID" 2>/dev/null || true
  fi
  if [[ "$COMPOSE_STARTED" -eq 1 ]]; then
    docker compose -f "$COMPOSE_FILE" down >/dev/null 2>&1 || true
  fi
}
trap cleanup EXIT INT TERM

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1" >&2
    echo "Install it or use an alternate flag (e.g. --docker for server, --client-only)." >&2
    exit 1
  fi
}

bootstrap_server_native() {
  require_command python3
  load_env
  cd "$SERVER"
  if [[ ! -d .venv ]]; then
    log "creating Python venv in server/.venv"
    python3 -m venv .venv
  fi
  # shellcheck disable=SC1091
  source .venv/bin/activate
  pip install -q -r requirements.txt
  python manage.py migrate --noinput
}

start_server_native() {
  bootstrap_server_native
  cd "$SERVER"
  # shellcheck disable=SC1091
  source .venv/bin/activate
  local base
  base="$(api_base_url)"
  log "starting Django (API_BASE_URL=$base, mode=${NASYAD_MODE:-debug})"
  local host_port="127.0.0.1:8000"
  if [[ "$base" =~ ^https?://([^/]+) ]]; then
    host_port="${BASH_REMATCH[1]}"
  fi
  python manage.py runserver "$host_port" >/tmp/nasyad-server.log 2>&1 &
  SERVER_PID=$!
  wait_for_health
}

write_compose_env() {
  # Docker Compose env_file must be a single file — flatten .env/ for compose.
  local flat="$ENV_DIR/.compose.env"
  {
    [[ -f "$ENV_DIR/app.env" ]] && cat "$ENV_DIR/app.env"
    echo
    [[ -f "$ENV_DIR/server.env" ]] && cat "$ENV_DIR/server.env"
  } >"$flat"
  echo "$flat"
}

start_server_docker() {
  require_command docker
  if ! docker compose version >/dev/null 2>&1; then
    echo "Docker Compose v2 required (docker compose)." >&2
    exit 1
  fi
  load_env
  local flat
  flat="$(write_compose_env)"
  log "starting server via Docker Compose (env: $flat)"
  docker compose -f "$COMPOSE_FILE" --env-file "$flat" up -d --build
  COMPOSE_STARTED=1
  wait_for_health
}

bootstrap_client() {
  require_command flutter
  load_env
  cd "$CLIENT"
  # shellcheck source=/dev/null
  source "$CLIENT/tool/pub_env.sh"
  flutter pub get
}

flutter_dart_defines() {
  local defines=()
  if [[ -n "${API_BASE_URL:-}" ]]; then
    defines+=(--dart-define=API_BASE_URL="$API_BASE_URL")
  fi
  if [[ -n "${GITHUB_OWNER:-}" ]]; then
    defines+=(--dart-define=GITHUB_OWNER="$GITHUB_OWNER")
  fi
  if [[ -n "${GITHUB_REPO:-}" ]]; then
    defines+=(--dart-define=GITHUB_REPO="$GITHUB_REPO")
  fi
  printf '%s\n' "${defines[@]}"
}

run_client() {
  require_command flutter
  load_env
  cd "$CLIENT"
  # shellcheck source=/dev/null
  source "$CLIENT/tool/pub_env.sh"
  local defines=()
  mapfile -t defines < <(flutter_dart_defines)
  log "starting Flutter (API_BASE_URL=$(api_base_url))"
  exec flutter run "${defines[@]}" "${FLUTTER_ARGS[@]}"
}

case "$MODE" in
  all)
    if [[ "$USE_DOCKER" -eq 1 ]]; then
      start_server_docker
    else
      start_server_native
    fi
    bootstrap_client
    [[ "$SETUP_ONLY" -eq 1 ]] && { log "setup complete"; exit 0; }
    run_client
    ;;
  server)
    if [[ "$USE_DOCKER" -eq 1 ]]; then
      start_server_docker
    else
      start_server_native
    fi
    [[ "$SETUP_ONLY" -eq 1 ]] && { log "setup complete"; exit 0; }
    log "server running — Ctrl+C to stop"
    if [[ "$USE_DOCKER" -eq 1 ]]; then
      flat="$(write_compose_env)"
      docker compose -f "$COMPOSE_FILE" --env-file "$flat" logs -f server
    else
      wait "$SERVER_PID"
    fi
    ;;
  client)
    bootstrap_client
    [[ "$SETUP_ONLY" -eq 1 ]] && { log "setup complete"; exit 0; }
    run_client
    ;;
esac
