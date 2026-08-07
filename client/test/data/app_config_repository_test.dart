import 'package:flutter_test/flutter_test.dart';

import 'package:nasyad/data/datasources/app_config_remote_datasource.dart';
import 'package:nasyad/data/local/app_config_store.dart';
import 'package:nasyad/data/repositories/app_config_repository_impl.dart';
import 'package:nasyad/domain/app_config_keys.dart';
import 'package:nasyad/domain/entities/app_config_snapshot.dart';

class _FakeRemote implements AppConfigRemoteDataSource {
  _FakeRemote({this.result, this.error});

  AppConfigSnapshot? result;
  Object? error;
  int fetchCalls = 0;
  String? lastToken;

  @override
  Future<AppConfigSnapshot> fetch({String? token}) async {
    fetchCalls++;
    lastToken = token;
    final err = error;
    if (err != null) throw err;
    return result ?? AppConfigSnapshot.empty;
  }
}

void main() {
  group('AppConfigRepositoryImpl', () {
    test('defaults missing keys to false before any fetch', () {
      final repo = AppConfigRepositoryImpl(
        store: AppConfigStore.memory(),
        remote: _FakeRemote(),
      );
      expect(repo.isEnabled(AppConfigKeys.exampleRemoteFlag), isFalse);
      expect(repo.isEnabled('anything'), isFalse);
    });

    test('hydrate loads cache into memory', () async {
      final store = AppConfigStore.memory(
        initial: const AppConfigSnapshot(
          features: {AppConfigKeys.exampleRemoteFlag: true},
        ),
      );
      final repo = AppConfigRepositoryImpl(store: store, remote: _FakeRemote());
      await repo.hydrate();
      expect(repo.isEnabled(AppConfigKeys.exampleRemoteFlag), isTrue);
      await repo.dispose();
    });

    test('refresh applies remote and writes cache', () async {
      final store = AppConfigStore.memory();
      final remote = _FakeRemote(
        result: AppConfigSnapshot(
          features: const {AppConfigKeys.exampleRemoteFlag: true},
          updatedAt: DateTime.utc(2026, 8, 8, 12),
        ),
      );
      final clock = DateTime.utc(2026, 8, 8, 12, 5);
      final repo = AppConfigRepositoryImpl(
        store: store,
        remote: remote,
        clock: () => clock,
      );

      await repo.refresh(token: 'abc');
      expect(remote.fetchCalls, 1);
      expect(remote.lastToken, 'abc');
      expect(repo.isEnabled(AppConfigKeys.exampleRemoteFlag), isTrue);
      expect(repo.current.fetchedAt, clock);

      final cached = await store.read();
      expect(cached!.isEnabled(AppConfigKeys.exampleRemoteFlag), isTrue);
      await repo.dispose();
    });

    test('refresh keeps cache when remote fails', () async {
      final store = AppConfigStore.memory(
        initial: const AppConfigSnapshot(
          features: {AppConfigKeys.exampleRemoteFlag: true},
        ),
      );
      final remote = _FakeRemote(error: Exception('offline'));
      final repo = AppConfigRepositoryImpl(store: store, remote: remote);
      await repo.hydrate();
      expect(repo.isEnabled(AppConfigKeys.exampleRemoteFlag), isTrue);

      await repo.refresh();
      expect(remote.fetchCalls, 1);
      expect(repo.isEnabled(AppConfigKeys.exampleRemoteFlag), isTrue);
      await repo.dispose();
    });

    test('refresh keeps defaults when remote fails with empty cache', () async {
      final remote = _FakeRemote(error: Exception('500'));
      final repo = AppConfigRepositoryImpl(
        store: AppConfigStore.memory(),
        remote: remote,
      );
      await repo.refresh();
      expect(repo.isEnabled(AppConfigKeys.exampleRemoteFlag), isFalse);
      await repo.dispose();
    });

    test(
      'applies remote features and ignores unknown keys on read path',
      () async {
        final remote = _FakeRemote(
          result: const AppConfigSnapshot(
            features: {
              AppConfigKeys.exampleRemoteFlag: true,
              'future_flag': false,
            },
          ),
        );
        final repo = AppConfigRepositoryImpl(
          store: AppConfigStore.memory(),
          remote: remote,
        );
        await repo.refresh();
        expect(repo.isEnabled(AppConfigKeys.exampleRemoteFlag), isTrue);
        expect(repo.isEnabled('future_flag'), isFalse);
        expect(repo.isEnabled('never_seen'), isFalse);
        await repo.dispose();
      },
    );
  });
}
