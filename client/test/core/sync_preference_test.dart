import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:nasyad/core/preferences/sync_preference_cubit.dart';
import 'package:nasyad/core/preferences/sync_preference_store.dart';
import 'package:nasyad/core/sync/network_status_reader.dart';
import 'package:nasyad/domain/services/local_sync_coordinator.dart';
import 'package:nasyad/domain/services/sync_policy.dart';

void main() {
  group('SyncPreferenceStore', () {
    test('defaults to true when unset', () async {
      final store = SyncPreferenceStore.memory();
      expect(await store.read(), isTrue);
      store.dispose();
    });

    test('write false persists and notifies changes', () async {
      final store = SyncPreferenceStore.memory();
      expect(store.changes, emits(null));
      await store.write(false);
      expect(await store.read(), isFalse);
      store.dispose();
    });

    test('memory initial false is respected', () async {
      final store = SyncPreferenceStore.memory(initial: false);
      expect(await store.read(), isFalse);
      store.dispose();
    });
  });

  group('SyncPolicy', () {
    test('attempts remote only when preference on and online', () {
      expect(
        SyncPolicy.shouldAttemptRemoteSync(
          preferenceEnabled: true,
          isOnline: true,
        ),
        isTrue,
      );
      expect(
        SyncPolicy.shouldAttemptRemoteSync(
          preferenceEnabled: true,
          isOnline: false,
        ),
        isFalse,
      );
      expect(
        SyncPolicy.shouldAttemptRemoteSync(
          preferenceEnabled: false,
          isOnline: true,
        ),
        isFalse,
      );
      expect(
        SyncPolicy.shouldAttemptRemoteSync(
          preferenceEnabled: false,
          isOnline: false,
        ),
        isFalse,
      );
    });
  });

  group('LocalSyncCoordinator', () {
    test('returns skippedDisabled when preference off', () async {
      final store = SyncPreferenceStore.memory(initial: false);
      final coordinator = LocalSyncCoordinator(
        preferenceStore: store,
        networkStatus: const AlwaysOnlineNetworkStatus(),
      );
      expect(await coordinator.tick(), SyncTickResult.skippedDisabled);
      store.dispose();
    });

    test('returns skippedOffline when preference on but offline', () async {
      final store = SyncPreferenceStore.memory(initial: true);
      final coordinator = LocalSyncCoordinator(
        preferenceStore: store,
        networkStatus: const OfflineNetworkStatus(),
      );
      expect(await coordinator.tick(), SyncTickResult.skippedOffline);
      store.dispose();
    });

    test('returns readyButNoRemote when preference on and online', () async {
      final store = SyncPreferenceStore.memory(initial: true);
      final coordinator = LocalSyncCoordinator(
        preferenceStore: store,
        networkStatus: const AlwaysOnlineNetworkStatus(),
      );
      expect(await coordinator.tick(), SyncTickResult.readyButNoRemote);
      store.dispose();
    });
  });

  group('SyncPreferenceCubit', () {
    test('defaults to true and toggles preference', () async {
      final store = SyncPreferenceStore.memory();
      final cubit = SyncPreferenceCubit(store: store);
      expect(cubit.state, isTrue);

      await cubit.setEnabled(false);
      expect(cubit.state, isFalse);
      expect(await store.read(), isFalse);

      await cubit.setEnabled(true);
      expect(cubit.state, isTrue);
      expect(await store.read(), isTrue);

      await cubit.close();
      store.dispose();
    });

    test('loads persisted false from store', () async {
      final store = SyncPreferenceStore.memory(initial: false);
      final cubit = SyncPreferenceCubit(store: store);
      await pumpEventQueue();
      expect(cubit.state, isFalse);
      await cubit.close();
      store.dispose();
    });
  });

  group('LookupNetworkStatusReader', () {
    test('reports online when lookup returns addresses', () async {
      final reader = LookupNetworkStatusReader(
        lookup: (_) async => [InternetAddress.loopbackIPv4],
      );
      expect(await reader.isOnline, isTrue);
    });

    test('reports offline on empty lookup or timeout', () async {
      final empty = LookupNetworkStatusReader(lookup: (_) async => []);
      expect(await empty.isOnline, isFalse);

      final timedOut = LookupNetworkStatusReader(
        timeout: const Duration(milliseconds: 10),
        lookup: (_) => Future.delayed(
          const Duration(seconds: 1),
          () => [InternetAddress.loopbackIPv4],
        ),
      );
      expect(await timedOut.isOnline, isFalse);
    });
  });
}
