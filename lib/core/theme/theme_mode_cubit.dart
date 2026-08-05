import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nasyad/core/theme/theme_mode_preference_store.dart';

class ThemeModeCubit extends Cubit<ThemeMode> {
  ThemeModeCubit({
    ThemeModePreferenceStore? store,
    ThemeMode initialMode = ThemeMode.system,
  }) : _store = store ?? ThemeModePreferenceStore(),
       super(initialMode) {
    _hydrating = _load();
  }

  final ThemeModePreferenceStore _store;
  Future<void>? _hydrating;

  Future<void> _load() async {
    final value = await _store.read();
    if (!isClosed && value != state) {
      emit(value);
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _hydrating;
    if (state == mode) return;
    emit(mode);
    await _store.write(mode);
  }
}
