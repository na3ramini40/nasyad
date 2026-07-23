import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nasyad/core/utils/id_generator.dart';
import 'package:nasyad/domain/entities/device.dart';
import 'package:nasyad/domain/entities/device_status.dart';
import 'package:nasyad/domain/entities/maintenance_rule.dart';
import 'package:nasyad/domain/entities/schedule_type.dart';
import 'package:nasyad/domain/usecases/device/create_device_usecase.dart';
import 'package:nasyad/domain/usecases/device/delete_device_usecase.dart';
import 'package:nasyad/domain/usecases/device/get_device_usecase.dart';
import 'package:nasyad/domain/usecases/device/get_rules_for_device_usecase.dart';
import 'package:nasyad/domain/usecases/device/update_device_usecase.dart';
import 'package:nasyad/presentation/device/maintenance_rule_presets.dart';

part 'device_edit_event.dart';
part 'device_edit_state.dart';

class DeviceEditBloc extends Bloc<DeviceEditEvent, DeviceEditState> {
  DeviceEditBloc({
    this.deviceId,
    required GetDeviceUsecase getDevice,
    required GetRulesForDeviceUsecase getRulesForDevice,
    required CreateDeviceUsecase createDevice,
    required UpdateDeviceUsecase updateDevice,
    required DeleteDeviceUsecase deleteDevice,
  }) : _getDevice = getDevice,
       _getRulesForDevice = getRulesForDevice,
       _createDevice = createDevice,
       _updateDevice = updateDevice,
       _deleteDevice = deleteDevice,
       super(DeviceEditState(isEdit: deviceId != null)) {
    on<DeviceEditStarted>(_onStarted);
    on<DeviceEditNameChanged>(_onNameChanged);
    on<DeviceEditScheduleTypeChanged>(_onScheduleTypeChanged);
    on<DeviceEditIntervalChanged>(_onIntervalChanged);
    on<DeviceEditIntervalUnitChanged>(_onIntervalUnitChanged);
    on<DeviceEditSuggestionApplied>(_onSuggestionApplied);
    on<DeviceEditSaveRequested>(_onSave);
    on<DeviceEditDeleteRequested>(_onDelete);
  }

  final String? deviceId;
  final GetDeviceUsecase _getDevice;
  final GetRulesForDeviceUsecase _getRulesForDevice;
  final CreateDeviceUsecase _createDevice;
  final UpdateDeviceUsecase _updateDevice;
  final DeleteDeviceUsecase _deleteDevice;

  Device? _existing;
  String? _existingRuleId;
  DateTime? _existingRuleCreatedAt;

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
      final rules = await _getRulesForDevice(deviceId!);
      _existing = device;

      ScheduleType? scheduleType;
      String? intervalUnit;
      var intervalValue = '';

      if (rules.isNotEmpty) {
        final rule = rules.first;
        _existingRuleId = rule.id;
        _existingRuleCreatedAt = rule.createdAt;
        scheduleType = rule.scheduleType == ScheduleType.fixedDate
            ? ScheduleType.calendarInterval
            : rule.scheduleType;
        intervalUnit = rule.intervalUnit;
        if (rule.intervalValue != null) {
          intervalValue = '${rule.intervalValue}';
        }
      }

      emit(
        state.copyWith(
          status: DeviceEditStatus.ready,
          name: device?.name ?? '',
          scheduleType: scheduleType,
          intervalUnit: intervalUnit,
          intervalValue: intervalValue,
          clearScheduleType: scheduleType == null,
          clearIntervalUnit: intervalUnit == null,
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

  void _onScheduleTypeChanged(
    DeviceEditScheduleTypeChanged event,
    Emitter<DeviceEditState> emit,
  ) {
    emit(
      state.copyWith(scheduleType: event.scheduleType, clearIntervalUnit: true),
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

  void _onSuggestionApplied(
    DeviceEditSuggestionApplied event,
    Emitter<DeviceEditState> emit,
  ) {
    final suggestion = event.suggestion;
    emit(
      state.copyWith(
        scheduleType: suggestion.scheduleType,
        intervalUnit: suggestion.intervalUnit,
        intervalValue: '${suggestion.intervalValue}',
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

    final amount = int.tryParse(state.intervalValue.trim());
    if (amount == null || amount <= 0) {
      emit(
        state.copyWith(
          status: DeviceEditStatus.failure,
          errorMessage: event.intervalAmountRequiredMessage,
        ),
      );
      return;
    }

    emit(state.copyWith(status: DeviceEditStatus.saving, clearError: true));

    final now = DateTime.now();
    final id = deviceId ?? IdGenerator.newId();
    final device = Device(
      id: id,
      name: name,
      description: _existing?.description,
      status: _existing?.status ?? DeviceStatus.active,
      currentUsage: _existing?.currentUsage ?? 0,
      usageAtLastMaintenance: _existing?.usageAtLastMaintenance ?? 0,
      createdAt: _existing?.createdAt ?? now,
      updatedAt: now,
    );

    final rule = MaintenanceRule(
      id: _existingRuleId ?? IdGenerator.newId(),
      deviceId: id,
      name: event.ruleName,
      scheduleType: state.scheduleType!,
      intervalValue: amount,
      intervalUnit: state.intervalUnit,
      createdAt: _existingRuleCreatedAt ?? now,
      updatedAt: now,
    );

    try {
      if (state.isEdit) {
        await _updateDevice(device, rule);
      } else {
        await _createDevice(device, rule);
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
