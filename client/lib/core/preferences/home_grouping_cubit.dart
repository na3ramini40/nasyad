import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nasyad/core/preferences/home_grouping_preference_store.dart';
import 'package:nasyad/domain/entities/home_grouping.dart';

class HomeGroupingCubit extends Cubit<HomeGrouping> {
  HomeGroupingCubit({
    HomeGroupingPreferenceStore? store,
    HomeGrouping initial = HomeGrouping.defaultValue,
  }) : _store = store ?? HomeGroupingPreferenceStore(),
       super(initial) {
    _load();
  }

  final HomeGroupingPreferenceStore _store;

  Future<void> _load() async {
    final value = await _store.read();
    if (!isClosed && value != state) {
      emit(value);
    }
  }

  Future<void> setGrouping(HomeGrouping value) async {
    if (state == value) return;
    emit(value);
    await _store.write(value);
  }
}
