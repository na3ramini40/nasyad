---
name: crecreate
description: >-
  Implements Flutter tests from natural-language scenarios for Nasyad. Maps
  user-described behavior to app layers, fixtures, and test types. Use when
  the user invokes /crecreate, describes a test scenario, or asks to implement
  or recreate tests from behavior descriptions.
---

# Crecreate — scenario → test

Turn a described scenario into a **correct, runnable** test in this repo. Simple, direct, robust.

**Authority:** existing tests in `test/` > [scenarios.md](scenarios.md) > [nasyad-flutter](../nasyad-flutter/SKILL.md).

## On invoke

1. **Parse** the scenario — restate in one line using Nasyad terms (screen, bloc, entity, route, preference).
2. **Locate context** — read the code under test; scan sibling tests; check [app-map](../nasyad-product/app-map.md) if the scenario is user-visible.
3. **Pick layer** (see table below).
4. **Implement** — reuse helpers; match naming and structure of nearby tests.
5. **Run** — `source tool/pub_env.sh && flutter test <path>` until green.

## Layer pick

| Scenario signal | Where | Harness |
|-----------------|-------|---------|
| Calculation, parsing, codec, migration SQL | `test/core/`, `test/domain/`, `test/data/` | plain `test()` |
| BLoC/Cubit emits states on events/streams | `test/presentation/*_bloc_test.dart` | `Fake*Repository`, `fixtures.dart`, `expectLater` + `emitsInOrder` |
| Tap, navigate, visible copy, theme/locale | `test/widget_test.dart` or feature widget file | `_testServices()`, `setupSqliteForTests`, `pumpAndSettle` |
| HTTP datasource / release JSON | `test/data/` | `http` `MockClient` |

When unsure: prefer the **lowest layer** that fully proves the scenario.

## Rules

- Reuse `test/helpers/fixtures.dart`, `fake_repositories.dart`, `fake_transfer_file_actions.dart` — extend fakes before inventing mocks (`mocktail` is not active).
- Drift tests: `NativeDatabase.memory()` + `setupSqliteForTests()` in `setUpAll`.
- Name tests after **behavior**, not implementation (`'filter change hides birthday reminders'`, not `'calls _applyFilter'`).
- One scenario → one focused `test` or `group`; no unrelated coverage.
- Do not edit `*.g.dart`. Do not commit unless asked.
- After adding tests meant for a PR: `/verify-ci`.

## Scenario translation

Read [scenarios.md](scenarios.md) when mapping informal language to layers and assertions.
