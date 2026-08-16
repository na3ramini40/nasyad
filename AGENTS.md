# Nasyad — agent instructions

Local-first maintenance tracker (devices + birthdays). Monorepo: **client** (Flutter) + **server** (Django REST). Open source; production secrets and official releases are owner-only.

## Layout

```text
client/                  # Flutter app — local-first UI (Drift is source of truth)
  lib/
    core/                # router, theme, ui, calendar, version, app_services
    l10n/                # ARB files (en, fa)
    data/                # drift db (local/db/), models, repositories, datasources
    domain/              # entities, repo contracts, services, usecases/<feature>/
    presentation/        # <feature>/{bloc,pages,widgets}
  test/                  # mirrors lib/; helpers in test/helpers/
  tool/                  # ci_verify, pub_env, bump_version, signing scripts

server/                  # Django REST API — optional sync/auth
  config/                # settings + root urls — keep thin
  core/                  # health, shared helpers
  <domain>/              # one app per domain (devices, birthdays, …) → /api/<domain>/
  tool/check.sh          # server verify

tool/                    # dev.sh, ci_verify.sh (root wrappers)
docs/                    # domain.md + domain/ only (bible)
.cursor/                 # rules (gates), skills (knowledge), agents, commands
```

## Run and verify

| Task | Command |
|------|---------|
| Everything | `./tool/dev.sh` (`--setup` first time; `--client-only`, `--server-only`, `--docker`) |
| Local secrets / modes | `env.example/` → `.env/` then `./tool/env_apply.sh` |
| Verify (before any PR) | `./tool/ci_verify.sh` — **client + server** |
| Local pub (client) | `source client/tool/pub_env.sh` first — mirror, local only |

## .cursor index — everything off by default

Off by default; this file routes and agents (`.cursor/agents/`) decide what to read. Two exceptions are always-on because they guard irreversible mistakes: `delivery.mdc` (git + CI) and `security.mdc` (secrets). **Read the matching rule file before acting:**

| Before you… | Read |
|-------------|------|
| Write or change any code | `.cursor/rules/shared/quality.mdc` |
| Judge domain correctness, capabilities, entities, enums, or sync | `docs/domain.md` → matching shard under `docs/domain/` |
| Scope a feature or cross-feature work | `.cursor/rules/shared/scope.mdc` |
| Bump version, changelog, or tag | `.cursor/rules/shared/release.mdc` |
| Change schema, migrations, import/export, or delete flows | `.cursor/rules/shared/data-safety.mdc` |

Client/server gates attach automatically when their files are touched (`.cursor/rules/client/`, `.cursor/rules/server/`).

| Kind | Path | Contents |
|------|------|----------|
| Skills — shared | `.cursor/skills/shared/` | product (app-map, end-user, insights), api-contract, meta |
| Skills — client | `.cursor/skills/client/flutter/` | stack, layers, ui, l10n, testing, domains, deeplink |
| Skills — server | `.cursor/skills/server/django/` | workflow, domains |
| Agents | `.cursor/agents/` | conductor, flutter-agent, django-agent |
| Commands | `.cursor/commands/` | product-design, deliver-feature, verify, ship-pr, release, save-progress |

## Working style

- Brief and teaching-first; smallest change that ships; prefer packages over rewrites.
- Product ideas / mature a suggestion before code: `/product-design` (product skill consult). Feature delivery: `/deliver-feature` (conductor routes the rest).
- Stack-shaping dependency additions (DI, network clients, codegen) require updating this file in the same change.

## Current Stack (client extras)

Active packages live in `client/pubspec.yaml`. Notable additions beyond the Flutter/Drift/BLoC base:

- `local_auth`, `flutter_secure_storage` — optional app lock (PIN/password/biometric); secrets stay on device
- `shared_preferences` — non-secret prefs (locale, theme, lock method/timeout flags, …)
- Do not assume `get_it` / `injectable` / `freezed`
