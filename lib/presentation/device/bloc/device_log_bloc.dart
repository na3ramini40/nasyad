import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nasyad/core/utils/id_generator.dart';
import 'package:nasyad/domain/entities/device_log.dart';
import 'package:nasyad/domain/entities/interval_unit.dart';
import 'package:nasyad/domain/usecases/device_log/create_device_log_usecase.dart';

part 'device_log_event.dart';
part 'device_log_state.dart';

class DeviceLogBloc extends Bloc<DeviceLogEvent, DeviceLogFormState> {
  DeviceLogBloc({
    required this.deviceId,
    required CreateDeviceLogUsecase createDeviceLog,
  })  : _createDeviceLog = createDeviceLog,
        super(DeviceLogFormState(date: DateTime.now())) {
    on<DeviceLogNotesChanged>(_onNotesChanged);
    on<DeviceLogDateChanged>(_onDateChanged);
    on<DeviceLogUsageDeltaChanged>(_onUsageDeltaChanged);
    on<DeviceLogUsageUnitChanged>(_onUsageUnitChanged);
    on<DeviceLogSubmitRequested>(_onSubmit);
  }

  final String deviceId;
  final CreateDeviceLogUsecase _createDeviceLog;

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

  void _onUsageDeltaChanged(
    DeviceLogUsageDeltaChanged event,
    Emitter<DeviceLogFormState> emit,
  ) {
    emit(state.copyWith(usageDelta: event.usageDelta));
  }

  void _onUsageUnitChanged(
    DeviceLogUsageUnitChanged event,
    Emitter<DeviceLogFormState> emit,
  ) {
    emit(state.copyWith(usageUnit: event.usageUnit));
  }

  Future<void> _onSubmit(
    DeviceLogSubmitRequested event,
    Emitter<DeviceLogFormState> emit,
  ) async {
    final usageText = state.usageDelta.trim();
    final usageDelta = usageText.isEmpty ? null : int.tryParse(usageText);
    if (usageText.isNotEmpty && usageDelta == null) {
      return;
    }
    if (usageDelta != null && state.usageUnit == null) {
      emit(
        state.copyWith(
          status: DeviceLogStatus.failure,
          errorMessage: event.usageUnitRequiredMessage,
        ),
      );
      return;
    }

    emit(state.copyWith(status: DeviceLogStatus.saving, clearError: true));

    final now = DateTime.now();
    final log = DeviceLog(
      id: IdGenerator.newId(),
      deviceId: deviceId,
      date: DateTime(state.date.year, state.date.month, state.date.day),
      notes: state.notes.trim().isEmpty ? null : state.notes.trim(),
      usageDelta: usageDelta,
      usageUnit: state.usageUnit,
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
