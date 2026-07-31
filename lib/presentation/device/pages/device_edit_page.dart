import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:nasyad/core/l10n/l10n.dart';
import 'package:nasyad/core/theme/app_spacing.dart';
import 'package:nasyad/core/ui/ui.dart';
import 'package:nasyad/domain/entities/interval_unit.dart';
import 'package:nasyad/domain/entities/schedule_type.dart';
import 'package:nasyad/presentation/device/bloc/device_edit_bloc.dart';
import 'package:nasyad/presentation/device/schedule_presets.dart';

class DeviceEditPage extends StatefulWidget {
  final String? deviceId;
  final String? parentId;

  const DeviceEditPage({super.key, this.deviceId, this.parentId});

  bool get isEdit => deviceId != null;

  @override
  State<DeviceEditPage> createState() => _DeviceEditPageState();
}

class _DeviceEditPageState extends State<DeviceEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _intervalController = TextEditingController();
  final _initialElapsedController = TextEditingController(text: '0');

  @override
  void dispose() {
    _nameController.dispose();
    _intervalController.dispose();
    _initialElapsedController.dispose();
    super.dispose();
  }

  void _syncControllers(DeviceEditState state) {
    if (_nameController.text != state.name) {
      _nameController.text = state.name;
    }
    if (_intervalController.text != state.intervalValue) {
      _intervalController.text = state.intervalValue;
    }
    if (_initialElapsedController.text != state.initialElapsed) {
      _initialElapsedController.text = state.initialElapsed;
    }
  }

  List<({String storage, String label})> _unitsFor(
    AppLocalizations l10n,
    ScheduleType type,
  ) {
    return switch (type) {
      ScheduleType.calendarInterval || ScheduleType.fixedDate => [
        (storage: CalendarIntervalUnit.days.storageValue, label: l10n.unitDays),
        (
          storage: CalendarIntervalUnit.weeks.storageValue,
          label: l10n.unitWeeks,
        ),
        (
          storage: CalendarIntervalUnit.months.storageValue,
          label: l10n.unitMonths,
        ),
      ],
      ScheduleType.usageInterval => [
        (storage: UsageIntervalUnit.hours.storageValue, label: l10n.unitHours),
        (storage: UsageIntervalUnit.km.storageValue, label: l10n.unitKm),
        (
          storage: UsageIntervalUnit.cycles.storageValue,
          label: l10n.unitCycles,
        ),
      ],
    };
  }

  void _save(AppLocalizations l10n) {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    context.read<DeviceEditBloc>().add(
      DeviceEditSaveRequested(
        nameRequiredMessage: l10n.deviceNameRequired,
        selectScheduleTypeMessage: l10n.selectScheduleType,
        selectIntervalUnitMessage: l10n.selectIntervalUnit,
        intervalAmountRequiredMessage: l10n.intervalAmountRequired,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isEdit = widget.isEdit;
    final suggestions = scheduleSuggestions(l10n);
    final theme = Theme.of(context);
    final muted = theme.textTheme.titleSmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w500,
    );

    return BlocConsumer<DeviceEditBloc, DeviceEditState>(
      listenWhen: (previous, current) =>
          previous.status != current.status ||
          previous.errorMessage != current.errorMessage ||
          previous.name != current.name ||
          previous.intervalValue != current.intervalValue ||
          previous.initialElapsed != current.initialElapsed,
      listener: (context, state) {
        _syncControllers(state);
        if (state.status == DeviceEditStatus.saved) {
          context.pop();
        } else if (state.status == DeviceEditStatus.deleted) {
          context.go('/');
        } else if (state.status == DeviceEditStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },
      builder: (context, state) {
        if (state.status == DeviceEditStatus.loading ||
            state.status == DeviceEditStatus.initial) {
          return Scaffold(
            appBar: AppBar(
              title: Text(isEdit ? l10n.editDevice : l10n.addEditDevice),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
              tooltip: l10n.back,
            ),
            title: Text(isEdit ? l10n.editDevice : l10n.addEditDevice),
            actions: [
              if (isEdit)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: state.isBusy
                      ? null
                      : () => context.read<DeviceEditBloc>().add(
                          const DeviceEditDeleteRequested(),
                        ),
                  tooltip: l10n.delete,
                ),
            ],
          ),
          body: AppContent(
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  AppTextField(
                    controller: _nameController,
                    label: l10n.deviceName,
                    hintText: l10n.deviceNameHint,
                    textInputAction: TextInputAction.next,
                    onChanged: (value) => context.read<DeviceEditBloc>().add(
                      DeviceEditNameChanged(value),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.deviceNameRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(l10n.scheduleSection, style: muted),
                  const SizedBox(height: AppSpacing.xs),
                  SelectableOptionTile(
                    label: l10n.noSchedule,
                    selected: !state.scheduleEnabled,
                    onTap: () => context.read<DeviceEditBloc>().add(
                      const DeviceEditScheduleEnabledChanged(false),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  SelectableOptionTile(
                    label: l10n.scheduleByTime,
                    selected:
                        state.scheduleEnabled &&
                        state.scheduleType == ScheduleType.calendarInterval,
                    onTap: () => context.read<DeviceEditBloc>().add(
                      const DeviceEditScheduleTypeChanged(
                        ScheduleType.calendarInterval,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  SelectableOptionTile(
                    label: l10n.scheduleByUsage,
                    selected:
                        state.scheduleEnabled &&
                        state.scheduleType == ScheduleType.usageInterval,
                    onTap: () => context.read<DeviceEditBloc>().add(
                      const DeviceEditScheduleTypeChanged(
                        ScheduleType.usageInterval,
                      ),
                    ),
                  ),
                  if (state.scheduleEnabled) ...[
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      controller: _intervalController,
                      label: l10n.intervalAmount,
                      hintText: l10n.intervalAmountHint,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (value) => context.read<DeviceEditBloc>().add(
                        DeviceEditIntervalChanged(value),
                      ),
                      validator: (value) {
                        if (!state.scheduleEnabled) return null;
                        final amount = int.tryParse(value?.trim() ?? '');
                        if (amount == null || amount <= 0) {
                          return l10n.intervalAmountRequired;
                        }
                        return null;
                      },
                    ),
                    if (state.scheduleType != null) ...[
                      const SizedBox(height: AppSpacing.lg),
                      Text(l10n.intervalUnit, style: muted),
                      const SizedBox(height: AppSpacing.xs),
                      for (final unit in _unitsFor(l10n, state.scheduleType!))
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                          child: SelectableOptionTile(
                            label: unit.label,
                            selected: state.intervalUnit == unit.storage,
                            onTap: () => context.read<DeviceEditBloc>().add(
                              DeviceEditIntervalUnitChanged(unit.storage),
                            ),
                          ),
                        ),
                    ],
                    if (!isEdit) ...[
                      const SizedBox(height: AppSpacing.lg),
                      AppTextField(
                        controller: _initialElapsedController,
                        label: l10n.initialElapsed,
                        hintText: l10n.initialElapsedHint,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) =>
                            context.read<DeviceEditBloc>().add(
                              DeviceEditInitialElapsedChanged(value),
                            ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    Text(l10n.suggestions, style: muted),
                    const SizedBox(height: AppSpacing.xs),
                    for (final suggestion in suggestions)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                        child: SelectableOptionTile(
                          label: suggestion.label,
                          selected:
                              state.scheduleType == suggestion.scheduleType &&
                              state.intervalUnit == suggestion.intervalUnit &&
                              state.intervalValue.trim() ==
                                  '${suggestion.intervalValue}',
                          onTap: () => context.read<DeviceEditBloc>().add(
                            DeviceEditSuggestionApplied(suggestion),
                          ),
                        ),
                      ),
                  ],
                  if (state.parentId == null) ...[
                    const SizedBox(height: AppSpacing.lg),
                    Text(l10n.usageUnit, style: muted),
                    const SizedBox(height: AppSpacing.xs),
                    for (final unit in UsageIntervalUnit.values)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                        child: SelectableOptionTile(
                          label: usageUnitLabel(l10n, unit),
                          selected: state.usageUnit == unit ||
                              (state.usageUnit == null &&
                                  state.intervalUnit == unit.storageValue),
                          onTap: () => context.read<DeviceEditBloc>().add(
                            DeviceEditUsageUnitChanged(unit),
                          ),
                        ),
                      ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  AppButton(
                    label: l10n.save,
                    onPressed: state.isBusy ? null : () => _save(l10n),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
