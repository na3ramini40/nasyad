# Nasyad server (Django)

REST API backend for the Nasyad client. Domain logic lives in **Django apps** (`core`, `devices`, `birthdays`) so features can evolve independently.

## Setup

```bash
# From repo root — single .env/ control plane
cp -a env.example .env   # if missing; never commit .env/
./tool/env_apply.sh

cd server
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
python manage.py migrate
python manage.py runserver
```

Or: `./tool/dev.sh --server-only`.

Health check: http://127.0.0.1:8000/api/health/ (public)

## API docs (DEBUG only)

Interactive OpenAPI docs are registered only when `DJANGO_DEBUG` is true (default for local). They are not exposed when `DEBUG` is false.

| Path | What |
|------|------|
| http://127.0.0.1:8000/api/schema/swagger-ui/ | Swagger UI |
| http://127.0.0.1:8000/api/schema/redoc/ | ReDoc |
| http://127.0.0.1:8000/api/schema/ | Raw OpenAPI schema |

**Try it out:** Authorize with `Token <key>` (include the `Token` prefix). Obtain a token via the accounts login/OTP flow.

## Auth

Token auth (`Authorization: Token <key>`). Endpoints under `/api/auth/`:

| Method | Path | Notes |
|--------|------|-------|
| `POST` | `/api/auth/register/` | `{username, password}` → `{token, user_id, username}` (201) |
| `POST` | `/api/auth/token/` | same body/shape (200) |

All sync endpoints require authentication. Rows are isolated by `user` FK.

## Sync API

Pull cursors live on list endpoints (`updated_since` / `created_since`). Upserts are idempotent `PUT` by client-assigned `id` (LWW on `updated_at` for devices/birthdays; logs are append-idempotent on first write).

### Devices — `/api/devices/`

| Method | Path | Notes |
|--------|------|-------|
| `GET` | `/api/devices/?updated_since=` | `{results: [...]}` |
| `GET` | `/api/devices/<id>/` | owner only |
| `PUT` | `/api/devices/<id>/` | upsert + LWW; archive/delete cascades subtree |
| `GET` | `/api/devices/logs/?created_since=` | `{results: [...]}` |
| `GET` | `/api/devices/logs/<id>/` | owner only |
| `PUT` | `/api/devices/logs/<id>/` | create-once idempotent upsert |

### Birthdays — `/api/birthdays/`

| Method | Path | Notes |
|--------|------|-------|
| `GET` | `/api/birthdays/?updated_since=` | `{results: [...]}` |
| `GET` | `/api/birthdays/<id>/` | owner only |
| `PUT` | `/api/birthdays/<id>/` | upsert + LWW |

Place is local-only — no Place models or APIs on the server.

## Layout

```text
server/
  config/          # project settings, root urls
  core/            # health + auth (/api/health/, /api/auth/)
  devices/         # device tree + device logs sync API
  birthdays/       # birthday reminders sync API
  manage.py
  requirements.txt
```

Engineering rules: [`AGENTS.md`](../AGENTS.md). Domain bible: [`docs/domain.md`](../docs/domain.md) → [`docs/domain/`](../docs/domain/).
