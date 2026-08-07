import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nasyad/domain/entities/app_config_snapshot.dart';
import 'package:nasyad/domain/repositories/app_config_repository.dart';

/// Exposes remote feature flags to the widget tree.
///
/// Read flags with [isEnabled]; call [refresh] for a best-effort network update.
class AppConfigCubit extends Cubit<AppConfigSnapshot> {
  AppConfigCubit({required AppConfigRepository repository})
    : _repository = repository,
      super(repository.current) {
    _subscription = _repository.watch().listen((snapshot) {
      if (!isClosed) emit(snapshot);
    });
  }

  final AppConfigRepository _repository;
  StreamSubscription<AppConfigSnapshot>? _subscription;

  /// Unknown / missing keys → `false`.
  bool isEnabled(String key) => state.isEnabled(key);

  /// Best-effort remote refresh; failures keep last-known / defaults.
  Future<void> refresh({String? token}) async {
    await _repository.refresh(token: token);
    if (!isClosed) emit(_repository.current);
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
