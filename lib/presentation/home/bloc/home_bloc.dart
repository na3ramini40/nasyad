import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nasyad/domain/entities/home_reminder.dart';
import 'package:nasyad/domain/entities/home_reminder_filter.dart';
import 'package:nasyad/domain/usecases/home/watch_home_reminders_usecase.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc(this._watchHomeReminders) : super(const HomeInitial()) {
    on<HomeStarted>(_onStarted);
    on<HomeFilterChanged>(_onFilterChanged);
    on<_HomeRemindersUpdated>(_onRemindersUpdated);
    on<_HomeWatchFailed>(_onWatchFailed);
  }

  final WatchHomeRemindersUsecase _watchHomeReminders;
  StreamSubscription<List<HomeReminder>>? _subscription;
  HomeReminderFilter _filter = HomeReminderFilter.all;

  Future<void> _onStarted(HomeStarted event, Emitter<HomeState> emit) async {
    emit(const HomeLoading());
    await _resubscribe(emit);
  }

  Future<void> _onFilterChanged(
    HomeFilterChanged event,
    Emitter<HomeState> emit,
  ) async {
    _filter = event.filter;
    final current = state;
    if (current is HomeLoaded) {
      emit(HomeLoaded(allReminders: current.allReminders, filter: _filter));
      return;
    }
    await _resubscribe(emit);
  }

  Future<void> _resubscribe(Emitter<HomeState> emit) async {
    await _subscription?.cancel();
    _subscription = _watchHomeReminders(filter: HomeReminderFilter.all).listen(
      (items) => add(_HomeRemindersUpdated(items)),
      onError: (Object error, StackTrace _) => add(_HomeWatchFailed(error)),
    );
  }

  void _onRemindersUpdated(
    _HomeRemindersUpdated event,
    Emitter<HomeState> emit,
  ) {
    emit(HomeLoaded(allReminders: event.reminders, filter: _filter));
  }

  void _onWatchFailed(_HomeWatchFailed event, Emitter<HomeState> emit) {
    emit(HomeError(event.error.toString()));
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
