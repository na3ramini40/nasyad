import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nasyad/domain/entities/device.dart';
import 'package:nasyad/domain/usecases/device/restore_device_usecase.dart';
import 'package:nasyad/domain/usecases/device/watch_archived_root_devices_usecase.dart';

part 'archived_devices_event.dart';
part 'archived_devices_state.dart';

class ArchivedDevicesBloc
    extends Bloc<ArchivedDevicesEvent, ArchivedDevicesState> {
  ArchivedDevicesBloc({
    required WatchArchivedRootDevicesUsecase watchArchivedRootDevices,
    required RestoreDeviceUsecase restoreDevice,
  }) : _watchArchivedRootDevices = watchArchivedRootDevices,
       _restoreDevice = restoreDevice,
       super(const ArchivedDevicesInitial()) {
    on<ArchivedDevicesStarted>(_onStarted);
    on<_ArchivedDevicesUpdated>(_onUpdated);
    on<_ArchivedDevicesWatchFailed>(_onWatchFailed);
    on<ArchivedDevicesRestoreRequested>(_onRestore);
  }

  final WatchArchivedRootDevicesUsecase _watchArchivedRootDevices;
  final RestoreDeviceUsecase _restoreDevice;
  StreamSubscription<List<Device>>? _subscription;

  Future<void> _onStarted(
    ArchivedDevicesStarted event,
    Emitter<ArchivedDevicesState> emit,
  ) async {
    emit(const ArchivedDevicesLoading());
    await _subscription?.cancel();
    _subscription = _watchArchivedRootDevices().listen(
      (items) => add(_ArchivedDevicesUpdated(items)),
      onError: (Object error, StackTrace _) =>
          add(_ArchivedDevicesWatchFailed(error)),
    );
  }

  void _onUpdated(
    _ArchivedDevicesUpdated event,
    Emitter<ArchivedDevicesState> emit,
  ) {
    emit(ArchivedDevicesLoaded(event.devices));
  }

  void _onWatchFailed(
    _ArchivedDevicesWatchFailed event,
    Emitter<ArchivedDevicesState> emit,
  ) {
    emit(ArchivedDevicesError(event.error.toString()));
  }

  Future<void> _onRestore(
    ArchivedDevicesRestoreRequested event,
    Emitter<ArchivedDevicesState> emit,
  ) async {
    final current = state;
    try {
      await _restoreDevice(event.id);
    } catch (error) {
      if (current is ArchivedDevicesLoaded) {
        emit(ArchivedDevicesRestoreFailed(error.toString()));
        emit(ArchivedDevicesLoaded(current.devices));
      } else {
        emit(ArchivedDevicesError(error.toString()));
      }
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
