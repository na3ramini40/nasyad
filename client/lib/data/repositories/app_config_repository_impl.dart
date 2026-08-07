import 'dart:async';

import 'package:nasyad/data/datasources/app_config_remote_datasource.dart';
import 'package:nasyad/data/local/app_config_store.dart';
import 'package:nasyad/domain/entities/app_config_snapshot.dart';
import 'package:nasyad/domain/repositories/app_config_repository.dart';

class AppConfigRepositoryImpl implements AppConfigRepository {
  AppConfigRepositoryImpl({
    required AppConfigStore store,
    required AppConfigRemoteDataSource remote,
    DateTime Function()? clock,
  }) : _store = store,
       _remote = remote,
       _clock = clock ?? DateTime.now;

  final AppConfigStore _store;
  final AppConfigRemoteDataSource _remote;
  final DateTime Function() _clock;

  AppConfigSnapshot _current = AppConfigSnapshot.empty;
  final _controller = StreamController<AppConfigSnapshot>.broadcast();

  @override
  AppConfigSnapshot get current => _current;

  @override
  bool isEnabled(String key) => _current.isEnabled(key);

  @override
  Stream<AppConfigSnapshot> watch() async* {
    yield _current;
    yield* _controller.stream;
  }

  void _setCurrent(AppConfigSnapshot snapshot) {
    _current = snapshot;
    if (!_controller.isClosed) {
      _controller.add(snapshot);
    }
  }

  @override
  Future<void> hydrate() async {
    final cached = await _store.read();
    if (cached != null) {
      _setCurrent(cached);
    }
  }

  @override
  Future<void> refresh({String? token}) async {
    try {
      final remote = await _remote.fetch(token: token);
      final snapshot = AppConfigSnapshot(
        features: remote.features,
        updatedAt: remote.updatedAt,
        fetchedAt: _clock().toUtc(),
      );
      await _store.write(snapshot);
      _setCurrent(snapshot);
    } catch (_) {
      // Keep last-known cache / defaults — never block or crash.
    }
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}
