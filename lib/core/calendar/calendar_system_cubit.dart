import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nasyad/core/calendar/calendar_preference_store.dart';
import 'package:nasyad/domain/entities/calendar_system.dart';

class CalendarSystemCubit extends Cubit<CalendarSystem> {
  CalendarSystemCubit({
    CalendarPreferenceStore? store,
    CalendarSystem initial = CalendarSystem.gregorian,
  }) : _store = store ?? CalendarPreferenceStore(),
       super(initial) {
    _load();
  }

  final CalendarPreferenceStore _store;

  Future<void> _load() async {
    final value = await _store.read();
    if (!isClosed && value != state) {
      emit(value);
    }
  }

  Future<void> setCalendarSystem(CalendarSystem system) async {
    if (state == system) return;
    emit(system);
    await _store.write(system);
  }
}
