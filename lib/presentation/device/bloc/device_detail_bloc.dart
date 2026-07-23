import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nasyad/domain/entities/device_log.dart';
import 'package:nasyad/domain/entities/device_summary.dart';
import 'package:nasyad/domain/usecases/device/archive_device_usecase.dart';
import 'package:nasyad/domain/usecases/device/watch_device_summaries_usecase.dart';
import 'package:nasyad/domain/usecases/device_log/watch_logs_for_device_usecase.dart';

part 'device_detail_event.dart';
part 'device_detail_state.dart';

class DeviceDetailBloc extends Bloc<DeviceDetailEvent, DeviceDetailState> {
  DeviceDetailBloc({
    required this.deviceId,
    required WatchDeviceSummariesUsecase watchDeviceSummaries,
    required WatchLogsForDeviceUsecase watchLogsForDevice,
    required ArchiveDeviceUsecase archiveDevice,
  })  : _watchDeviceSummaries = watchDeviceSummaries,
        _watchLogsForDevice = watchLogsForDevice,
        _archiveDevice = archiveDevice,
        super(const DeviceDetailLoading()) {
    on<DeviceDetailStarted>(_onStarted);
    on<_DeviceDetailSummaryUpdated>(_onSummaryUpdated);
    on<_DeviceDetailLogsUpdated>(_onLogsUpdated);
    on<_DeviceDetailWatchFailed>(_onWatchFailed);
    on<DeviceDetailArchiveRequested>(_onArchive);
  }

  final String deviceId;
  final WatchDeviceSummariesUsecase _watchDeviceSummaries;
  final WatchLogsForDeviceUsecase _watchLogsForDevice;
  final ArchiveDeviceUsecase _archiveDevice;

  StreamSubscription<List<DeviceSummary>>? _summarySub;
  StreamSubscription<List<DeviceLog>>? _logsSub;
  DeviceSummary? _summary;
  List<DeviceLog> _logs = const [];
  var _summaryReceived = false;

  Future<void> _onStarted(
    DeviceDetailStarted event,
    Emitter<DeviceDetailState> emit,
  ) async {
    emit(const DeviceDetailLoading());
    await _summarySub?.cancel();
    await _logsSub?.cancel();
    _summary = null;
    _logs = const [];
    _summaryReceived = false;

    _summarySub = _watchDeviceSummaries().listen(
      (items) {
        final match = items.where((item) => item.device.id == deviceId);
        add(_DeviceDetailSummaryUpdated(match.isEmpty ? null : match.first));
      },
      onError: (Object error, StackTrace _) =>
          add(_DeviceDetailWatchFailed(error)),
    );

    _logsSub = _watchLogsForDevice(deviceId).listen(
      (logs) => add(_DeviceDetailLogsUpdated(logs)),
      onError: (Object error, StackTrace _) =>
          add(_DeviceDetailWatchFailed(error)),
    );
  }

  void _onSummaryUpdated(
    _DeviceDetailSummaryUpdated event,
    Emitter<DeviceDetailState> emit,
  ) {
    _summaryReceived = true;
    _summary = event.summary;
    _emitLoaded(emit);
  }

  void _onLogsUpdated(
    _DeviceDetailLogsUpdated event,
    Emitter<DeviceDetailState> emit,
  ) {
    _logs = event.logs;
    if (_summaryReceived) _emitLoaded(emit);
  }

  void _emitLoaded(Emitter<DeviceDetailState> emit) {
    final summary = _summary;
    if (summary == null) {
      emit(const DeviceDetailNotFound());
      return;
    }
    emit(DeviceDetailLoaded(summary: summary, logs: _logs));
  }

  void _onWatchFailed(
    _DeviceDetailWatchFailed event,
    Emitter<DeviceDetailState> emit,
  ) {
    emit(DeviceDetailError(event.error.toString()));
  }

  Future<void> _onArchive(
    DeviceDetailArchiveRequested event,
    Emitter<DeviceDetailState> emit,
  ) async {
    try {
      await _archiveDevice(deviceId);
      emit(const DeviceDetailArchived());
    } catch (error) {
      emit(DeviceDetailError(error.toString()));
    }
  }

  @override
  Future<void> close() async {
    await _summarySub?.cancel();
    await _logsSub?.cancel();
    return super.close();
  }
}
