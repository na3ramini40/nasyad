import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nasyad/core/theme/season_theme_preference_store.dart';
import 'package:nasyad/domain/entities/season_theme.dart';

class SeasonThemeCubit extends Cubit<SeasonTheme> {
  SeasonThemeCubit({
    SeasonThemePreferenceStore? store,
    SeasonTheme initial = SeasonTheme.classic,
  }) : _store = store ?? SeasonThemePreferenceStore(),
       super(initial) {
    _hydrating = _load();
  }

  final SeasonThemePreferenceStore _store;
  Future<void>? _hydrating;

  Future<void> _load() async {
    final value = await _store.read();
    if (!isClosed && value != state) {
      emit(value);
    }
  }

  Future<void> setSeasonTheme(SeasonTheme season) async {
    await _hydrating;
    if (state == season) return;
    emit(season);
    await _store.write(season);
  }
}
