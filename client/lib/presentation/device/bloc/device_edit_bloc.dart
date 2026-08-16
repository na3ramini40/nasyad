import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nasyad/core/utils/id_generator.dart';
import 'package:nasyad/domain/entities/device.dart';
import 'package:nasyad/domain/entities/device_category_preset.dart';
import 'package:nasyad/domain/entities/device_status.dart';
import 'package:nasyad/domain/entities/interval_unit.dart';
import 'package:nasyad/domain/entities/schedule_type.dart';
import 'package:nasyad/domain/usecases/device/create_device_usecase.dart';
import 'package:nasyad/domain/usecases/device/delete_device_usecase.dart';
import 'package:nasyad/domain/usecases/device/get_device_usecase.dart';
import 'package:nasyad/domain/usecases/device/update_device_usecase.dart';
import 'package:nasyad/domain/entities/schedule_template.dart';
import 'package:nasyad/domain/entities/tag.dart';
import 'package:nasyad/domain/services/schedule_due_offset.dart';
import 'package:nasyad/domain/services/schedule_template_catalog.dart';
import 'package:nasyad/domain/usecases/tag/create_tag_usecase.dart';
import 'package:nasyad/domain/usecases/tag/set_device_tags_usecase.dart';
import 'package:nasyad/domain/usecases/tag/watch_tags_for_device_usecase.dart';
import 'package:nasyad/domain/usecases/tag/watch_tags_usecase.dart';

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
    WatchTagsUsecase? watchTags,
    WatchTagsForDeviceUsecase? watchTagsForDevice,
    CreateTagUsecase? createTag,
    SetDeviceTagsUsecase? setDeviceTags,
  }) : _getDevice = getDevice,
       _createDevice = createDevice,
       _updateDevice = updateDevice,
       _deleteDevice = deleteDevice,
       _watchTags = watchTags,
       _watchTagsForDevice = watchTagsForDevice,
       _createTag = createTag,
       _setDeviceTags = setDeviceTags,
       super(DeviceEditState(isEdit: deviceId != null, parentId: parentId)) {
    on<DeviceEditStarted>(_onStarted);
    on<DeviceEditNameChanged>(_onNameChanged);
    on<DeviceEditCategoryPresetChanged>(_onCategoryPresetChanged);
    on<DeviceEditLocationLabelChanged>(_onLocationLabelChanged);
    on<DeviceEditNotesChanged>(_onNotesChanged);
    on<DeviceEditScheduleEnabledChanged>(_onScheduleEnabledChanged);
    on<DeviceEditScheduleTypeChanged>(_onScheduleTypeChanged);
    on<DeviceEditIntervalChanged>(_onIntervalChanged);
    on<DeviceEditIntervalUnitChanged>(_onIntervalUnitChanged);
    on<DeviceEditInitialElapsedChanged>(_onInitialElapsedChanged);
    on<DeviceEditUsageUnitChanged>(_onUsageUnitChanged);
    on<DeviceEditUseParentUsageChanged>(_onUseParentUsageChanged);
    on<DeviceEditTemplateApplied>(_onTemplateApplied);
    on<DeviceEditTagToggled>(_onTagToggled);
    on<DeviceEditTagCreateRequested>(_onTagCreate);
    on<_DeviceEditTagsCatalogUpdated>(_onTagsCatalogUpdated);
    on<DeviceEditSaveRequested>(_onSave);
    on<DeviceEditDeleteRequested>(_onDelete);
  }

  final String? deviceId;
  final String? parentId;
  final GetDeviceUsecase _getDevice;
  final CreateDeviceUsecase _createDevice;
  final UpdateDeviceUsecase _updateDevice;
  final DeleteDeviceUsecase _deleteDevice;
  final WatchTagsUsecase? _watchTags;
  final WatchTagsForDeviceUsecase? _watchTagsForDevice;
  final CreateTagUsecase? _createTag;
  final SetDeviceTagsUsecase? _setDeviceTags;

  Device? _existing;
  StreamSubscription? _tagsSub;

  Future<void> _onStarted(
    DeviceEditStarted event,
    Emitter<DeviceEditState> emit,
  ) async {
    emit(state.copyWith(status: DeviceEditStatus.loading));
    try {
      final templates = await ScheduleTemplateCatalog.load();
      final watchTags = _watchTags;
      if (watchTags != null) {
        await _tagsSub?.cancel();
        _tagsSub = watchTags().listen(
          (tags) => add(_DeviceEditTagsCatalogUpdated(tags)),
        );
      }

      if (deviceId == null) {
        emit(
          state.copyWith(status: DeviceEditStatus.ready, templates: templates),
        );
        return;
      }

      final device = await _getDevice(deviceId!);
      _existing = device;
      final resolvedParentId = device?.parentId ?? parentId;
      final isChild = resolvedParentId != null;
      final inheritsParentUsage = isChild && device?.usageUnit == null;

      var selectedTagIds = const <String>[];
      final watchForDevice = _watchTagsForDevice;
      if (watchForDevice != null) {
        selectedTagIds = (await watchForDevice(
          deviceId!,
        ).first).map((tag) => tag.id).toList(growable: false);
      }

      emit(
        state.copyWith(
          status: DeviceEditStatus.ready,
          templates: templates,
          name: device?.name ?? '',
          categoryPreset: device?.categoryPreset,
          locationLabel: device?.locationLabel ?? '',
          notes: device?.description ?? '',
          parentId: resolvedParentId,
          scheduleEnabled: device?.hasSchedule ?? false,
          scheduleType: device?.scheduleType,
          intervalUnit: device?.intervalUnit,
          intervalValue: device?.intervalValue?.toString() ?? '',
          fixedDueAt: device?.fixedDueAt,
          usageUnit: device?.usageUnit,
          useParentUsage: inheritsParentUsage,
          selectedTagIds: selectedTagIds,
          clearScheduleType: device?.scheduleType == null,
          clearIntervalUnit: device?.intervalUnit == null,
          clearUsageUnit: device?.usageUnit == null,
          clearFixedDueAt: device?.fixedDueAt == null,
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

  void _onCategoryPresetChanged(
    DeviceEditCategoryPresetChanged event,
    Emitter<DeviceEditState> emit,
  ) {
    emit(state.copyWith(categoryPreset: event.categoryPreset));
  }

  void _onLocationLabelChanged(
    DeviceEditLocationLabelChanged event,
    Emitter<DeviceEditState> emit,
  ) {
    emit(state.copyWith(locationLabel: event.locationLabel));
  }

  void _onNotesChanged(
    DeviceEditNotesChanged event,
    Emitter<DeviceEditState> emit,
  ) {
    emit(state.copyWith(notes: event.notes));
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
          clearFixedDueAt: true,
          intervalValue: '',
          appliedTemplateId: null,
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
        clearFixedDueAt: event.scheduleType != ScheduleType.fixedDate,
        appliedTemplateId: null,
      ),
    );
  }

  void _onIntervalChanged(
    DeviceEditIntervalChanged event,
    Emitter<DeviceEditState> emit,
  ) {
    emit(
      state.copyWith(
        intervalValue: event.intervalValue,
        appliedTemplateId: null,
      ),
    );
  }

  void _onIntervalUnitChanged(
    DeviceEditIntervalUnitChanged event,
    Emitter<DeviceEditState> emit,
  ) {
    emit(
      state.copyWith(intervalUnit: event.intervalUnit, appliedTemplateId: null),
    );
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
    emit(state.copyWith(usageUnit: event.usageUnit, useParentUsage: false));
  }

  void _onUseParentUsageChanged(
    DeviceEditUseParentUsageChanged event,
    Emitter<DeviceEditState> emit,
  ) {
    if (event.useParentUsage) {
      emit(state.copyWith(useParentUsage: true, clearUsageUnit: true));
    } else {
      emit(state.copyWith(useParentUsage: false));
    }
  }

  void _onTemplateApplied(
    DeviceEditTemplateApplied event,
    Emitter<DeviceEditState> emit,
  ) {
    final template = event.template;
    final fixedDueAt = template.scheduleType == ScheduleType.fixedDate
        ? dueDateFromInterval(
            intervalValue: template.intervalValue,
            intervalUnit: template.intervalUnit,
            from: DateTime.now(),
          )
        : null;

    final inherits = state.isChild && state.useParentUsage;
    final templateUsageUnit =
        template.scheduleType == ScheduleType.usageInterval
        ? UsageIntervalUnitX.fromStorage(template.intervalUnit)
        : null;

    emit(
      state.copyWith(
        scheduleEnabled: true,
        scheduleType: template.scheduleType,
        intervalUnit: template.intervalUnit,
        intervalValue: '${template.intervalValue}',
        fixedDueAt: fixedDueAt,
        clearFixedDueAt: fixedDueAt == null,
        appliedTemplateId: template.id,
        usageUnit: inherits ? null : (templateUsageUnit ?? state.usageUnit),
        clearUsageUnit: inherits,
        useParentUsage: inherits,
      ),
    );
  }

  void _onTagToggled(
    DeviceEditTagToggled event,
    Emitter<DeviceEditState> emit,
  ) {
    final selected = List<String>.from(state.selectedTagIds);
    if (selected.contains(event.tagId)) {
      selected.remove(event.tagId);
    } else {
      selected.add(event.tagId);
    }
    emit(state.copyWith(selectedTagIds: selected));
  }

  Future<void> _onTagCreate(
    DeviceEditTagCreateRequested event,
    Emitter<DeviceEditState> emit,
  ) async {
    final name = event.name.trim();
    if (name.isEmpty) return;
    final createTag = _createTag;
    if (createTag == null) return;

    final existing = state.availableTags
        .where((tag) => tag.name.toLowerCase() == name.toLowerCase())
        .toList(growable: false);
    if (existing.isNotEmpty) {
      final tagId = existing.first.id;
      if (!state.selectedTagIds.contains(tagId)) {
        emit(state.copyWith(selectedTagIds: [...state.selectedTagIds, tagId]));
      }
      return;
    }

    final now = DateTime.now();
    final tag = Tag(
      id: IdGenerator.newId(),
      name: name,
      createdAt: now,
      updatedAt: now,
    );
    await createTag(tag);
    emit(
      state.copyWith(
        selectedTagIds: [...state.selectedTagIds, tag.id],
        availableTags: [...state.availableTags, tag]
          ..sort((a, b) => a.name.compareTo(b.name)),
      ),
    );
  }

  void _onTagsCatalogUpdated(
    _DeviceEditTagsCatalogUpdated event,
    Emitter<DeviceEditState> emit,
  ) {
    emit(state.copyWith(availableTags: event.tags));
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

    final notes = state.notes.trim();
    final location = state.locationLabel.trim();

    emit(state.copyWith(status: DeviceEditStatus.saving, clearError: true));

    final now = DateTime.now();
    final id = deviceId ?? IdGenerator.newId();
    final isChild = (state.parentId ?? _existing?.parentId) != null;
    final UsageIntervalUnit? resolvedUsageUnit;
    if (isChild && state.useParentUsage) {
      resolvedUsageUnit = null;
    } else {
      resolvedUsageUnit =
          state.usageUnit ??
          (state.scheduleType == ScheduleType.usageInterval &&
                  state.intervalUnit != null
              ? UsageIntervalUnitX.fromStorage(state.intervalUnit!)
              : null);
    }

    final device = Device(
      id: id,
      parentId: state.parentId ?? _existing?.parentId,
      name: name,
      description: notes.isEmpty ? null : notes,
      categoryPreset: state.categoryPreset,
      locationLabel: location.isEmpty ? null : location,
      status: _existing?.status ?? DeviceStatus.active,
      usageUnit: resolvedUsageUnit,
      currentUsage: _existing?.currentUsage ?? 0,
      scheduleType: state.scheduleEnabled ? state.scheduleType : null,
      intervalValue: state.scheduleEnabled ? amount : null,
      intervalUnit: state.scheduleEnabled ? state.intervalUnit : null,
      fixedDueAt: state.scheduleEnabled
          ? (state.scheduleType == ScheduleType.fixedDate
                ? state.fixedDueAt
                : _existing?.fixedDueAt)
          : null,
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
      final setTags = _setDeviceTags;
      if (setTags != null) {
        await setTags(id, state.selectedTagIds);
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

  @override
  Future<void> close() async {
    await _tagsSub?.cancel();
    return super.close();
  }
}
