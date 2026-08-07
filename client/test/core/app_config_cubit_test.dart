import 'package:flutter_test/flutter_test.dart';

import 'package:nasyad/core/app_config/app_config_cubit.dart';
import 'package:nasyad/data/datasources/app_config_remote_datasource.dart';
import 'package:nasyad/data/local/app_config_store.dart';
import 'package:nasyad/data/repositories/app_config_repository_impl.dart';
import 'package:nasyad/domain/app_config_keys.dart';
import 'package:nasyad/domain/entities/app_config_snapshot.dart';

class _FakeRemote implements AppConfigRemoteDataSource {
  _FakeRemote(this.result);

  final AppConfigSnapshot result;

  @override
  Future<AppConfigSnapshot> fetch({String? token}) async => result;
}

void main() {
  group('AppConfigCubit', () {
    test('isEnabled defaults to false for unknown keys', () async {
      final repo = AppConfigRepositoryImpl(
        store: AppConfigStore.memory(),
        remote: _FakeRemote(AppConfigSnapshot.empty),
      );
      final cubit = AppConfigCubit(repository: repo);
      expect(cubit.isEnabled(AppConfigKeys.exampleRemoteFlag), isFalse);
      expect(cubit.isEnabled('missing'), isFalse);
      await cubit.close();
      await repo.dispose();
    });

    test('refresh updates isEnabled from remote', () async {
      final repo = AppConfigRepositoryImpl(
        store: AppConfigStore.memory(),
        remote: _FakeRemote(
          const AppConfigSnapshot(
            features: {AppConfigKeys.exampleRemoteFlag: true},
          ),
        ),
      );
      final cubit = AppConfigCubit(repository: repo);
      expect(cubit.isEnabled(AppConfigKeys.exampleRemoteFlag), isFalse);

      await cubit.refresh();
      expect(cubit.isEnabled(AppConfigKeys.exampleRemoteFlag), isTrue);
      await cubit.close();
      await repo.dispose();
    });

    test('reflects hydrated repository current', () async {
      final repo = AppConfigRepositoryImpl(
        store: AppConfigStore.memory(
          initial: const AppConfigSnapshot(
            features: {AppConfigKeys.exampleRemoteFlag: true},
          ),
        ),
        remote: _FakeRemote(AppConfigSnapshot.empty),
      );
      await repo.hydrate();
      final cubit = AppConfigCubit(repository: repo);
      expect(cubit.isEnabled(AppConfigKeys.exampleRemoteFlag), isTrue);
      await cubit.close();
      await repo.dispose();
    });

    test('picks up repository.refresh via watch', () async {
      final repo = AppConfigRepositoryImpl(
        store: AppConfigStore.memory(),
        remote: _FakeRemote(
          const AppConfigSnapshot(
            features: {AppConfigKeys.exampleRemoteFlag: true},
          ),
        ),
      );
      final cubit = AppConfigCubit(repository: repo);
      expect(cubit.isEnabled(AppConfigKeys.exampleRemoteFlag), isFalse);

      await repo.refresh();
      // Allow async watch delivery.
      await Future<void>.delayed(Duration.zero);
      expect(cubit.isEnabled(AppConfigKeys.exampleRemoteFlag), isTrue);
      await cubit.close();
      await repo.dispose();
    });
  });
}
