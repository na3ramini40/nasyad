import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nasyad/core/preferences/sync_preference_store.dart';

class SyncPreferenceCubit extends Cubit<bool> {
  SyncPreferenceCubit({
    SyncPreferenceStore? store,
    bool initial = SyncPreferenceStore.defaultEnabled,
  }) : _store = store ?? SyncPreferenceStore(),
       super(initial) {
    _hydrating = _load();
  }

  final SyncPreferenceStore _store;
  Future<void>? _hydrating;

  Future<void> _load() async {
    final value = await _store.read();
    if (!isClosed && value != state) {
      emit(value);
    }
  }

  Future<void> setEnabled(bool enabled) async {
    await _hydrating;
    if (state == enabled) return;
    emit(enabled);
    await _store.write(enabled);
  }
}
