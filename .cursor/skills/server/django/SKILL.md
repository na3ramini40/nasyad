---
name: nasyad-django
description: >-
  Django REST backend for Nasyad — modular domain apps, DRF, migrations,
  tests, and sync endpoints. Use when changing anything under server/.
---

# Nasyad Django (server)

REST API in `server/`. One Django app per domain; `config/` thin; shared helpers in `core/`. Hard gates in `.cursor/rules/server/server.mdc`; domain specifics in [domains.md](domains.md).

## Workflow

1. Read the existing app before adding endpoints or models.
2. Routes in `<app>/urls.py`, included from `config/urls.py` under `/api/<app>/`.
3. Model change → `makemigrations` + `migrate`; prefer additive.
4. Verify: `cd server && source .venv/bin/activate && ./tool/check.sh`.

## Patterns

- Standard DRF: models → serializers → views/viewsets → urls; permission classes for auth.
- Apps import from `core/`, never from another app's views; cross-domain references by explicit IDs in payloads (FK across apps only for stable dependencies).
- API shape changes that the client consumes go through `.cursor/skills/shared/api-contract/` and ship with the client in one delivery.

## Testing

- Tests live in `<app>/tests.py` (or `<app>/tests/`); every endpoint gets request-level tests via DRF's `APITestCase`/`APIClient` — status codes, payload shape, auth/permission denials, and validation errors.
- Model logic and migrations with data at risk get their own tests.
- Run until green: `cd server && source .venv/bin/activate && python manage.py test` (also part of `./tool/check.sh`).
