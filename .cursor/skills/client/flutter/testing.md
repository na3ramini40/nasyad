# Testing — scenario → test

Turn described behavior into the smallest runnable test. Authority: existing tests in `client/test/` > this file.

## Pick the lowest layer that fully proves the scenario

| Signal | Where | Harness |
|--------|-------|---------|
| Calculation, parsing, codec, migration | `test/core|domain|data/` | plain `test()` |
| Bloc emits states on events/streams | `test/presentation/*_bloc_test.dart` | fake repos + `expectLater` / `emitsInOrder` |
| Tap, navigate, visible copy, locale/theme | widget test | `_testServices()`, `setupSqliteForTests`, `pumpAndSettle` |
| HTTP datasource / release JSON | `test/data/` | `http` `MockClient` fixture |

## Scenario translation

| User says | Meaning | Test |
|-----------|---------|------|
| "nothing due" | empty Home reminders | widget — empty-state text after splash |
| "device due soon" | `MaintenanceStatus.soon` | bloc/domain — `sampleSummary(status: …)` |
| "log maintenance" | `DeviceLogKind.maintenanceDone` saved | bloc — assert fake repo `createLog` |
| "archive device" | `DeviceStatus.archived` subtree | bloc — `statusChanges` on fake repo |
| "switch to Persian" | `Locale('fa')` via prefs | widget — tap, expect fa string |
| "Shamsi date" | calendar pref affects formatting | domain/widget — set calendar store, assert label |
| "export/import" | transfer use case + bundle codec | domain — `FakeTransferFileActions` |
| "deep link" | `DeepLinkParser.parse` target | core — pure parser test |
| "migration from vN" | Drift schema step | data — open at old version, migrate, query |

## Rules

- Reuse `test/helpers/` (`fixtures.dart`, `fake_repositories.dart`, `fake_transfer_file_actions.dart`) — extend fakes, don't invent mocks (`mocktail` not active).
- Drift: `NativeDatabase.memory()` + `setupSqliteForTests()` in `setUpAll`.
- Name after behavior (`'filter change hides birthday reminders'`), not implementation.
- One scenario → one focused test/group; match sibling cleanup (`tearDown`, `bloc.close()`).
- Run until green: `source client/tool/pub_env.sh && cd client && flutter test <path>`.
