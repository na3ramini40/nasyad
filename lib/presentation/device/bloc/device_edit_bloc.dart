import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nasyad/core/utils/id_generator.dart';
import 'package:nasyad/domain/entities/device.dart';
import 'package:nasyad/domain/entities/device_status.dart';
import 'package:nasyad/domain/entities/interval_unit.dart';
import 'package:nasyad/domain/entities/schedule_type.dart';
import 'package:nasyad/domain/usecases/device/create_device_usecase.dart';
import 'package:nasyad/domain/usecases/device/delete_device_usecase.dart';
import 'package:nasyad/domain/usecases/device/get_device_usecase.dart';
import 'package:nasyad/domain/usecases/device/update_device_usecase.dart';
import 'package:nasyad/presentation/device/schedule_presets.dart';

part 'device_edit_event.dart';
part 'device_edit_state.dart';

class DeviceEditBloc extends Bloc<DeviceEditEvent, DeviceEditState> {
  DeviceEditBloc({
    this.deviceId,
    this.parentId,
    required GetDeviceUsecase getDevice,
    required CreateDeviceUsecase createDevice,
    required UpdateDeviceUsecase updateDevice,
    required DeleteDeviceUsecase deleteDevice,
  }) : _getDevice = getDevice,
       _createDevice = createDevice,
       _updateDevice = updateDevice,
       _deleteDevice = deleteDevice,
       super(DeviceEditState(isEdit: deviceId != null, parentId: parentId)) {
    on<DeviceEditStarted>(_onStarted);
    on<DeviceEditNameChanged>(_onNameChanged);
    on<DeviceEditScheduleEnabledChanged>(_onScheduleEnabledChanged);
    on<DeviceEditScheduleTypeChanged>(_onScheduleTypeChanged);
    on<DeviceEditIntervalChanged>(_onIntervalChanged);
    on<DeviceEditIntervalUnitChanged>(_onIntervalUnitChanged);
    on<DeviceEditInitialElapsedChanged>(_onInitialElapsedChanged);
    on<DeviceEditUsageUnitChanged>(_onUsageUnitChanged);
    on<DeviceEditSuggestionApplied>(_onSuggestionApplied);
    on<DeviceEditSaveRequested>(_onSave);
    on<DeviceEditDeleteRequested>(_onDelete);
  }

  final String? deviceId;
  final String? parentId;
  final GetDeviceUsecase _getDevice;
  final CreateDeviceUsecase _createDevice;
  final UpdateDeviceUsecase _updateDevice;
  final DeleteDeviceUsecase _deleteDevice;

  Device? _existing;

  Future<void> _onStarted(
    DeviceEditStarted event,
    Emitter<DeviceEditState> emit,
  ) async {
    if (deviceId == null) {
      emit(state.copyWith(status: DeviceEditStatus.ready));
      return;
    }

    emit(state.copyWith(status: DeviceEditStatus.loading));
    try {
      final device = await _getDevice(deviceId!);
      _existing = device;

      emit(
        state.copyWith(
          status: DeviceEditStatus.ready,
          name: device?.name ?? '',
          parentId: device?.parentId ?? parentId,
          scheduleEnabled: device?.hasSchedule ?? false,
          scheduleType: device?.scheduleType,
          intervalUnit: device?.intervalUnit,
          intervalValue: device?.intervalValue?.toString() ?? '',
          usageUnit: device?.usageUnit,
          clearScheduleType: device?.scheduleType == null,
          clearIntervalUnit: device?.intervalUnit == null,
          clearUsageUnit: device?.usageUnit == null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: DeviceEditStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void _onNameChanged(
    DeviceEditNameChanged event,
    Emitter<DeviceEditState> emit,
  ) {
    emit(state.copyWith(name: event.name));
  }

  void _onScheduleEnabledChanged(
    DeviceEditScheduleEnabledChanged event,
    Emitter<DeviceEditState> emit,
  ) {
    if (event.enabled) {
      emit(
        state.copyWith(
          scheduleEnabled: true,
          scheduleType: state.scheduleType ?? ScheduleType.calendarInterval,
        ),
      );
    } else {
      emit(
        state.copyWith(
          scheduleEnabled: false,
          clearScheduleType: true,
          clearIntervalUnit: true,
          intervalValue: '',
        ),
      );
    }
  }

  void _onScheduleTypeChanged(
    DeviceEditScheduleTypeChanged event,
    Emitter<DeviceEditState> emit,
  ) {
    emit(
      state.copyWith(
        scheduleEnabled: true,
        scheduleType: event.scheduleType,
        clearIntervalUnit: true,
      ),
    );
  }

  void _onIntervalChanged(
    DeviceEditIntervalChanged event,
    Emitter<DeviceEditState> emit,
  ) {
    emit(state.copyWith(intervalValue: event.intervalValue));
  }

  void _onIntervalUnitChanged(
    DeviceEditIntervalUnitChanged event,
    Emitter<DeviceEditState> emit,
  ) {
    emit(state.copyWith(intervalUnit: event.intervalUnit));
  }

  void _onInitialElapsedChanged(
    DeviceEditInitialElapsedChanged event,
    Emitter<DeviceEditState> emit,
  ) {
    emit(state.copyWith(initialElapsed: event.initialElapsed));
  }

  void _onUsageUnitChanged(
    DeviceEditUsageUnitChanged event,
    Emitter<DeviceEditState> emit,
  ) {
    emit(state.copyWith(usageUnit: event.usageUnit));
  }

  void _onSuggestionApplied(
    DeviceEditSuggestionApplied event,
    Emitter<DeviceEditState> emit,
  ) {
    final suggestion = event.suggestion;
    emit(
      state.copyWith(
        scheduleEnabled: true,
        scheduleType: suggestion.scheduleType,
        intervalUnit: suggestion.intervalUnit,
        intervalValue: '${suggestion.intervalValue}',
        usageUnit: suggestion.scheduleType == ScheduleType.usageInterval
            ? UsageIntervalUnitX.fromStorage(suggestion.intervalUnit)
            : state.usageUnit,
      ),
    );
  }

  Future<void> _onSave(
    DeviceEditSaveRequested event,
    Emitter<DeviceEditState> emit,
  ) async {
    final name = state.name.trim();
    if (name.isEmpty) {
      emit(
        state.copyWith(
          status: DeviceEditStatus.failure,
          errorMessage: event.nameRequiredMessage,
        ),
      );
      return;
    }

    int? amount;
    if (state.scheduleEnabled) {
      if (state.scheduleType == null) {
        emit(
          state.copyWith(
            status: DeviceEditStatus.failure,
            errorMessage: event.selectScheduleTypeMessage,
          ),
        );
        return;
      }
      if (state.intervalUnit == null) {
        emit(
          state.copyWith(
            status: DeviceEditStatus.failure,
            errorMessage: event.selectIntervalUnitMessage,
          ),
        );
        return;
      }
      amount = int.tryParse(state.intervalValue.trim());
      if (amount == null || amount <= 0) {
        emit(
          state.copyWith(
            status: DeviceEditStatus.failure,
            errorMessage: event.intervalAmountRequiredMessage,
          ),
        );
        return;
      }
    }

    final initialElapsed = int.tryParse(state.initialElapsed.trim()) ?? 0;
    if (initialElapsed < 0) return;

    emit(state.copyWith(status: DeviceEditStatus.saving, clearError: true));

    final now = DateTime.now();
    final id = deviceId ?? IdGenerator.newId();
    final resolvedUsageUnit =
        state.usageUnit ??
        (state.scheduleType == ScheduleType.usageInterval &&
                state.intervalUnit != null
            ? UsageIntervalUnitX.fromStorage(state.intervalUnit!)
            : null);

    final device = Device(
      id: id,
      parentId: state.parentId ?? _existing?.parentId,
      name: name,
      description: _existing?.description,
      status: _existing?.status ?? DeviceStatus.active,
      usageUnit: resolvedUsageUnit,
      currentUsage: _existing?.currentUsage ?? 0,
      scheduleType: state.scheduleEnabled ? state.scheduleType : null,
      intervalValue: state.scheduleEnabled ? amount : null,
      intervalUnit: state.scheduleEnabled ? state.intervalUnit : null,
      fixedDueAt: state.scheduleEnabled ? _existing?.fixedDueAt : null,
      lastMaintainedAt: _existing?.lastMaintainedAt ?? now,
      usageAtLastMaintenance: _existing?.usageAtLastMaintenance ?? 0,
      createdAt: _existing?.createdAt ?? now,
      updatedAt: now,
    );

    try {
      if (state.isEdit) {
        await _updateDevice(device);
      } else {
        await _createDevice(device, initialElapsed: initialElapsed);
      }
      emit(state.copyWith(status: DeviceEditStatus.saved));
    } catch (error) {
      emit(
        state.copyWith(
          status: DeviceEditStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onDelete(
    DeviceEditDeleteRequested event,
    Emitter<DeviceEditState> emit,
  ) async {
    if (deviceId == null) return;
    emit(state.copyWith(status: DeviceEditStatus.saving, clearError: true));
    try {
      await _deleteDevice(deviceId!);
      emit(state.copyWith(status: DeviceEditStatus.deleted));
    } catch (error) {
      emit(
        state.copyWith(
          status: DeviceEditStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
