---
name: nasyad-flutter
description: >-
  Flutter development for the Nasyad client — clean architecture, Drift, BLoC,
  UI composition, l10n/calendar, testing, and feature domains. Use when
  writing, refactoring, or testing any Dart/Flutter code under client/.
---

# Nasyad Flutter (client)

Senior Flutter work on `client/`. Smallest surface that ships; active stack only (root `AGENTS.md` + `client/pubspec.yaml`). Hard gates live in `.cursor/rules/client/client.mdc`.

## Shards — read the one you touch

| Topic | File |
|-------|------|
| Packages & choices | [stack.md](stack.md) |
| Layers, placement, Drift | [layers.md](layers.md) |
| UI composition & a11y | [ui.md](ui.md) |
| l10n (en/fa) & calendar | [l10n.md](l10n.md) |
| Tests from scenarios | [testing.md](testing.md) |
| Feature domains map | [domains.md](domains.md) |
| Deep links | [deeplink.md](deeplink.md) |

## Workflow

1. Read the relevant shard + existing code in the touched layer; match neighboring style.
2. `source client/tool/pub_env.sh` before local `flutter`/`dart pub`.
3. Change data → domain → presentation in the smallest slice; run codegen after Drift/annotation changes.
4. Handle loading / empty / error at boundaries; strings via ARB.
5. New behavior gets a test ([testing.md](testing.md)); PR-bound work runs `/verify`.
