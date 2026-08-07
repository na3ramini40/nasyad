import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nasyad/core/preferences/soon_window_preference_store.dart';
import 'package:nasyad/domain/entities/soon_window_days.dart';

class SoonWindowCubit extends Cubit<SoonWindowDays> {
  SoonWindowCubit({
    SoonWindowPreferenceStore? store,
    SoonWindowDays initial = SoonWindowDays.defaultValue,
  }) : _store = store ?? SoonWindowPreferenceStore(),
       super(initial) {
    _load();
  }

  final SoonWindowPreferenceStore _store;

  Future<void> _load() async {
    final value = await _store.read();
    if (!isClosed && value != state) {
      emit(value);
    }
  }

  Future<void> setSoonWindow(SoonWindowDays value) async {
    if (state == value) return;
    emit(value);
    await _store.write(value);
  }
}
