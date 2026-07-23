import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nasyad/domain/entities/device_summary.dart';
import 'package:nasyad/domain/usecases/device/watch_device_summaries_usecase.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc(this._watchDeviceSummaries) : super(const HomeInitial()) {
    on<HomeStarted>(_onStarted);
    on<_HomeSummariesUpdated>(_onSummariesUpdated);
    on<_HomeWatchFailed>(_onWatchFailed);
  }

  final WatchDeviceSummariesUsecase _watchDeviceSummaries;
  StreamSubscription<List<DeviceSummary>>? _subscription;

  Future<void> _onStarted(HomeStarted event, Emitter<HomeState> emit) async {
    emit(const HomeLoading());
    await _subscription?.cancel();
    _subscription = _watchDeviceSummaries().listen(
      (items) => add(_HomeSummariesUpdated(items)),
      onError: (Object error, StackTrace _) => add(_HomeWatchFailed(error)),
    );
  }

  void _onSummariesUpdated(
    _HomeSummariesUpdated event,
    Emitter<HomeState> emit,
  ) {
    emit(HomeLoaded(event.summaries));
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
