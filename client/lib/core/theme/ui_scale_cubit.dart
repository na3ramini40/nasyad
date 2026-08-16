import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nasyad/core/theme/ui_scale.dart';
import 'package:nasyad/core/theme/ui_scale_preference_store.dart';

class UiScaleCubit extends Cubit<double> {
  UiScaleCubit({
    UiScalePreferenceStore? store,
    double initialScale = UiScale.defaultValue,
  }) : _store = store ?? UiScalePreferenceStore(),
       super(UiScale.clamp(initialScale)) {
    _hydrating = _load();
  }

  final UiScalePreferenceStore _store;
  Future<void>? _hydrating;

  Future<void> _load() async {
    final value = await _store.read();
    if (!isClosed && value != state) {
      emit(value);
    }
  }

  Future<void> setScale(double scale) async {
    await _hydrating;
    final clamped = UiScale.clamp(scale);
    if (state == clamped) return;
    emit(clamped);
    await _store.write(clamped);
  }

  Future<void> reset() => setScale(UiScale.defaultValue);
}
