import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nasyad/domain/entities/device_summary.dart';
import 'package:nasyad/domain/usecases/device/watch_device_summaries_usecase.dart';

part 'device_list_event.dart';
part 'device_list_state.dart';

class DeviceListBloc extends Bloc<DeviceListEvent, DeviceListState> {
  DeviceListBloc(this._watchDeviceSummaries)
    : super(const DeviceListInitial()) {
    on<DeviceListStarted>(_onStarted);
    on<_DeviceListSummariesUpdated>(_onSummariesUpdated);
    on<_DeviceListWatchFailed>(_onWatchFailed);
  }

  final WatchDeviceSummariesUsecase _watchDeviceSummaries;
  StreamSubscription<List<DeviceSummary>>? _subscription;

  Future<void> _onStarted(
    DeviceListStarted event,
    Emitter<DeviceListState> emit,
  ) async {
    emit(const DeviceListLoading());
    await _subscription?.cancel();
    _subscription = _watchDeviceSummaries().listen(
      (items) => add(_DeviceListSummariesUpdated(items)),
      onError: (Object error, StackTrace _) =>
          add(_DeviceListWatchFailed(error)),
    );
  }

  void _onSummariesUpdated(
    _DeviceListSummariesUpdated event,
    Emitter<DeviceListState> emit,
  ) {
    emit(DeviceListLoaded(event.summaries));
  }

  void _onWatchFailed(
    _DeviceListWatchFailed event,
    Emitter<DeviceListState> emit,
  ) {
    emit(DeviceListError(event.error.toString()));
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
