# Scenario translation (Nasyad)

Informal phrase → what it means in this app → how to test.

## Product language → code

| User says | App meaning | Layer |
|-----------|-------------|-------|
| "nothing due" / empty home | Home reminders list empty | widget — `find.text('Nothing needs attention')` after splash |
| "device is due soon" | `MaintenanceStatus.soon` on summary | bloc or domain — `sampleSummary(status: MaintenanceStatus.soon)` |
| "log maintenance" | `DeviceLogKind.maintenanceDone` saved | bloc + fake repo — assert `createLog` called / state updated |
| "archive device" | `DeviceStatus.archived` subtree | bloc — `statusChanges` on fake repo |
| "switch to Persian" | `Locale('fa')` via preferences | widget — tap `'Persian'`, expect `'تنظیمات'` |
| "Shamsi date" | calendar preference affects formatting | widget or domain — set calendar cubit/store, assert formatted string |
| "export backup" / "import" | transfer use case + bundle codec | domain/usecases or presentation/transfer — `FakeTransferFileActions` |
| "deep link to device" | `DeepLinkDeviceView(id: …)` | core — `DeepLinkParser.parse(Uri.parse(...))` |
| "update available banner" | `AppUpdateBloc` + GitHub release | bloc or data — `MockClient` JSON fixture |
| "migration from vN" | Drift schema step | data — open DB at version, run migration, query |

## Assertion patterns

**Bloc stream**

```dart
expectLater(
  bloc.stream,
  emitsInOrder([const HomeLoading(), isA<HomeLoaded>()]),
);
bloc.add(const HomeStarted());
await Future<void>.delayed(Duration.zero);
deviceRepository.emitSummaries([sampleSummary()]);
```

**Widget navigation**

```dart
await tester.tap(find.byIcon(Icons.settings_outlined));
await tester.pumpAndSettle();
expect(find.text('Preferences'), findsOneWidget);
```

**Parser / pure function**

```dart
expect(DeepLinkParser.parse(Uri.parse('nasyad:///devices')), isA<DeepLinkDevices>());
```

## Anti-patterns

- Testing private methods or trivial getters.
- Duplicating a test that already exists one directory over — extend the existing file.
- Hard-coding fa strings when testing en-only logic (and vice versa) without setting locale.
- Skipping `tearDown` / `bloc.close()` / `_disposeApp` when the sibling tests clean up.
