import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:nasyad/core/l10n/l10n.dart';
import 'package:nasyad/core/theme/app_radius.dart';
import 'package:nasyad/core/theme/app_spacing.dart';
import 'package:nasyad/core/ui/ui.dart';
import 'package:nasyad/domain/entities/interval_unit.dart';
import 'package:nasyad/presentation/device/bloc/device_log_bloc.dart';

class DeviceLogPage extends StatefulWidget {
  const DeviceLogPage({super.key, required this.deviceId});

  final String deviceId;

  @override
  State<DeviceLogPage> createState() => _DeviceLogPageState();
}

class _DeviceLogPageState extends State<DeviceLogPage> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _usageController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    _usageController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(DateTime current) async {
    final l10n = AppLocalizations.of(context);
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: l10n.date,
      cancelText: l10n.back,
      confirmText: l10n.save,
    );
    if (picked != null && mounted) {
      context.read<DeviceLogBloc>().add(DeviceLogDateChanged(picked));
    }
  }

  String _dateLabel(Locale locale, DateTime date) {
    return DateFormat.yMMMEd(locale.toString()).format(date);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);

    return BlocConsumer<DeviceLogBloc, DeviceLogFormState>(
      listener: (context, state) {
        if (state.status == DeviceLogStatus.saved) {
          context.pop();
        } else if (state.status == DeviceLogStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back),
              tooltip: l10n.back,
            ),
            title: Text(l10n.addLog),
          ),
          body: AppContent(
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  AppTextField(
                    controller: _notesController,
                    label: l10n.notes,
                    hintText: l10n.notesHint,
                    maxLines: 4,
                    minLines: 3,
                    textInputAction: TextInputAction.newline,
                    onChanged: (value) => context.read<DeviceLogBloc>().add(
                      DeviceLogNotesChanged(value),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    l10n.date,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  InkWell(
                    onTap: () => _pickDate(state.date),
                    borderRadius: AppRadius.borderMd,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                      ),
                      child: Text(
                        _dateLabel(locale, state.date),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(
                    controller: _usageController,
                    label: l10n.usageDelta,
                    hintText: l10n.usageDeltaHint,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (value) => context.read<DeviceLogBloc>().add(
                      DeviceLogUsageDeltaChanged(value),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    l10n.usageUnit,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  for (final unit in UsageIntervalUnit.values)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: SelectableOptionTile(
                        label: switch (unit) {
                          UsageIntervalUnit.hours => l10n.unitHours,
                          UsageIntervalUnit.km => l10n.unitKm,
                          UsageIntervalUnit.cycles => l10n.unitCycles,
                        },
                        selected: state.usageUnit == unit,
                        onTap: () => context.read<DeviceLogBloc>().add(
                          DeviceLogUsageUnitChanged(unit),
                        ),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.xl),
                  AppButton(
                    label: l10n.submitLog,
                    onPressed: state.isSaving
                        ? null
                        : () {
                            if (!(_formKey.currentState?.validate() ?? false)) {
                              return;
                            }
                            context.read<DeviceLogBloc>().add(
                              DeviceLogSubmitRequested(
                                usageUnitRequiredMessage: l10n.usageUnit,
                              ),
                            );
                          },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
