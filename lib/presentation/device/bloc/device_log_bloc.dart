import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nasyad/core/utils/id_generator.dart';
import 'package:nasyad/domain/entities/device.dart';
import 'package:nasyad/domain/entities/device_log.dart';
import 'package:nasyad/domain/entities/device_log_kind.dart';
import 'package:nasyad/domain/entities/interval_unit.dart';
import 'package:nasyad/domain/usecases/device/get_device_usecase.dart';
import 'package:nasyad/domain/usecases/device_log/create_device_log_usecase.dart';
import 'package:nasyad/domain/services/maintenance_status_calculator.dart';

part 'device_log_event.dart';
part 'device_log_state.dart';

class DeviceLogBloc extends Bloc<DeviceLogEvent, DeviceLogFormState> {
  DeviceLogBloc({
    required this.deviceId,
    required CreateDeviceLogUsecase createDeviceLog,
    required GetDeviceUsecase getDevice,
    DeviceLogKind initialKind = DeviceLogKind.maintenanceDone,
    MaintenanceStatusCalculator? calculator,
  }) : _createDeviceLog = createDeviceLog,
       _getDevice = getDevice,
       _calculator = calculator ?? MaintenanceStatusCalculator(),
       super(DeviceLogFormState(date: DateTime.now(), kind: initialKind)) {
    on<DeviceLogStarted>(_onStarted);
    on<DeviceLogKindChanged>(_onKindChanged);
    on<DeviceLogNotesChanged>(_onNotesChanged);
    on<DeviceLogDateChanged>(_onDateChanged);
    on<DeviceLogUsageValueChanged>(_onUsageValueChanged);
    on<DeviceLogSubmitRequested>(_onSubmit);
  }

  final String deviceId;
  final CreateDeviceLogUsecase _createDeviceLog;
  final GetDeviceUsecase _getDevice;
  final MaintenanceStatusCalculator _calculator;

  Future<void> _onStarted(
    DeviceLogStarted event,
    Emitter<DeviceLogFormState> emit,
  ) async {
    emit(state.copyWith(status: DeviceLogStatus.loading));
    try {
      final device = await _getDevice(deviceId);
      final chain = <Device>[];
      Device? current = device;
      while (current != null) {
        chain.add(current);
        final parentId = current.parentId;
        current = parentId == null ? null : await _getDevice(parentId);
      }
      final byId = {for (final d in chain) d.id: d};
      final owner = device == null
          ? null
          : _calculator.resolveUsageOwner(device, byId);

      emit(
        state.copyWith(
          status: DeviceLogStatus.ready,
          device: device,
          usageOwner: owner,
          usageValue: owner == null ? '' : '${owner.currentUsage}',
          usageUnit: owner?.usageUnit,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: DeviceLogStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void _onKindChanged(
    DeviceLogKindChanged event,
    Emitter<DeviceLogFormState> emit,
  ) {
    emit(state.copyWith(kind: event.kind));
  }

  void _onNotesChanged(
    DeviceLogNotesChanged event,
    Emitter<DeviceLogFormState> emit,
  ) {
    emit(state.copyWith(notes: event.notes));
  }

  void _onDateChanged(
    DeviceLogDateChanged event,
    Emitter<DeviceLogFormState> emit,
  ) {
    emit(state.copyWith(date: event.date));
  }

  void _onUsageValueChanged(
    DeviceLogUsageValueChanged event,
    Emitter<DeviceLogFormState> emit,
  ) {
    emit(state.copyWith(usageValue: event.usageValue));
  }

  Future<void> _onSubmit(
    DeviceLogSubmitRequested event,
    Emitter<DeviceLogFormState> emit,
  ) async {
    int? usageValue;
    if (state.kind == DeviceLogKind.usageUpdate) {
      usageValue = int.tryParse(state.usageValue.trim());
      if (usageValue == null) {
        emit(
          state.copyWith(
            status: DeviceLogStatus.failure,
            errorMessage: event.usageReadingRequiredMessage,
          ),
        );
        return;
      }
    }

    emit(state.copyWith(status: DeviceLogStatus.saving, clearError: true));

    final now = DateTime.now();
    final log = DeviceLog(
      id: IdGenerator.newId(),
      deviceId: deviceId,
      date: DateTime(state.date.year, state.date.month, state.date.day),
      notes: state.notes.trim().isEmpty ? null : state.notes.trim(),
      kind: state.kind,
      usageValue: usageValue,
      usageUnit: state.usageOwner?.usageUnit ?? state.usageUnit,
      createdAt: now,
    );

    try {
      await _createDeviceLog(log);
      emit(state.copyWith(status: DeviceLogStatus.saved));
    } catch (error) {
      emit(
        state.copyWith(
          status: DeviceLogStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
