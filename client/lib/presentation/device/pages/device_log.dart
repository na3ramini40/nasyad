import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:nasyad/core/l10n/l10n.dart';
import 'package:nasyad/core/theme/app_radius.dart';
import 'package:nasyad/core/theme/app_spacing.dart';
import 'package:nasyad/core/ui/ui.dart';
import 'package:nasyad/domain/entities/device_log_kind.dart';
import 'package:nasyad/presentation/device/bloc/device_log_bloc.dart';
import 'package:nasyad/presentation/device/schedule_presets.dart';

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
  final _costController = TextEditingController();
  final _costCurrencyController = TextEditingController();
  final _vendorController = TextEditingController();
  final _imagePicker = ImagePicker();

  @override
  void dispose() {
    _notesController.dispose();
    _usageController.dispose();
    _costController.dispose();
    _costCurrencyController.dispose();
    _vendorController.dispose();
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

  Future<void> _pickPhoto() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 2048,
      maxHeight: 2048,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;
    final bytes = await picked.readAsBytes();
    if (!mounted) return;
    context.read<DeviceLogBloc>().add(
      DeviceLogPhotoSelected(bytes, picked.name),
    );
  }

  String _dateLabel(Locale locale, DateTime date) {
    return DateFormat.yMMMEd(locale.toString()).format(date);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final muted = Theme.of(context).textTheme.titleSmall?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w500,
    );

    return BlocConsumer<DeviceLogBloc, DeviceLogFormState>(
      listener: (context, state) {
        if (state.usageValue.isNotEmpty &&
            _usageController.text != state.usageValue &&
            state.status == DeviceLogStatus.ready) {
          _usageController.text = state.usageValue;
        }
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
        if (state.status == DeviceLogStatus.loading) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.addLog)),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final owner = state.usageOwner;
        final unit = owner?.usageUnit;

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
                  Text(l10n.logKind, style: muted),
                  const SizedBox(height: AppSpacing.xs),
                  SelectableOptionTile(
                    label: l10n.logKindMaintenance,
                    selected: state.kind == DeviceLogKind.maintenanceDone,
                    onTap: () => context.read<DeviceLogBloc>().add(
                      const DeviceLogKindChanged(DeviceLogKind.maintenanceDone),
                    ),
                  ),
                  if (owner != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    SelectableOptionTile(
                      label: l10n.logKindUsage,
                      selected: state.kind == DeviceLogKind.usageUpdate,
                      onTap: () => context.read<DeviceLogBloc>().add(
                        const DeviceLogKindChanged(DeviceLogKind.usageUpdate),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
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
                  AppTextField(
                    controller: _costController,
                    label: l10n.logCost,
                    hintText: l10n.logCostHint,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    ],
                    onChanged: (value) => context.read<DeviceLogBloc>().add(
                      DeviceLogCostValueChanged(value),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(
                    controller: _costCurrencyController,
                    label: l10n.logCostCurrency,
                    hintText: l10n.logCostCurrencyHint,
                    textInputAction: TextInputAction.next,
                    onChanged: (value) => context.read<DeviceLogBloc>().add(
                      DeviceLogCostCurrencyChanged(value),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(
                    controller: _vendorController,
                    label: l10n.logVendor,
                    hintText: l10n.logVendorHint,
                    textInputAction: TextInputAction.next,
                    onChanged: (value) => context.read<DeviceLogBloc>().add(
                      DeviceLogVendorChanged(value),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(l10n.logPhoto, style: muted),
                  const SizedBox(height: AppSpacing.xs),
                  if (state.hasPhoto) ...[
                    ClipRRect(
                      borderRadius: AppRadius.borderMd,
                      child: Image.memory(
                        state.photoBytes!,
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextButton.icon(
                      onPressed: () => context.read<DeviceLogBloc>().add(
                        const DeviceLogPhotoCleared(),
                      ),
                      icon: const Icon(Icons.delete_outline),
                      label: Text(l10n.logPhotoRemove),
                    ),
                  ] else
                    OutlinedButton.icon(
                      onPressed: _pickPhoto,
                      icon: const Icon(Icons.photo_outlined),
                      label: Text(l10n.logPhotoAttach),
                    ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(l10n.date, style: muted),
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
                  if (state.kind == DeviceLogKind.usageUpdate &&
                      owner != null) ...[
                    const SizedBox(height: AppSpacing.lg),
                    if (unit != null)
                      Text(
                        l10n.currentUsageLabel(
                          owner.currentUsage,
                          usageUnitLabel(l10n, unit),
                        ),
                        style: muted,
                      ),
                    const SizedBox(height: AppSpacing.sm),
                    AppTextField(
                      controller: _usageController,
                      label: unit == null
                          ? l10n.usageReading
                          : '${l10n.usageReading} (${usageUnitLabel(l10n, unit)})',
                      hintText: l10n.usageReadingHint,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (value) => context.read<DeviceLogBloc>().add(
                        DeviceLogUsageValueChanged(value),
                      ),
                      validator: (value) {
                        if (state.kind != DeviceLogKind.usageUpdate) {
                          return null;
                        }
                        if (value == null ||
                            int.tryParse(value.trim()) == null) {
                          return l10n.usageReadingRequired;
                        }
                        return null;
                      },
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  AppButton(
                    label: state.kind == DeviceLogKind.maintenanceDone
                        ? l10n.markMaintained
                        : l10n.updateUsage,
                    onPressed: state.isSaving
                        ? null
                        : () {
                            if (!(_formKey.currentState?.validate() ?? false)) {
                              return;
                            }
                            context.read<DeviceLogBloc>().add(
                              DeviceLogSubmitRequested(
                                usageReadingRequiredMessage:
                                    l10n.usageReadingRequired,
                                invalidCostMessage: l10n.logInvalidCost,
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
