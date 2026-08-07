import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:nasyad/core/l10n/l10n.dart';
import 'package:nasyad/core/theme/app_spacing.dart';
import 'package:nasyad/core/ui/log_photo_thumbnail.dart';
import 'package:nasyad/core/ui/ui.dart';
import 'package:nasyad/core/utils/log_cost_formatter.dart';
import 'package:nasyad/domain/entities/device_log.dart';
import 'package:nasyad/domain/entities/device_log_kind.dart';
import 'package:nasyad/domain/entities/device_summary.dart';
import 'package:nasyad/domain/entities/maintenance_status.dart';
import 'package:nasyad/presentation/device/bloc/device_detail_bloc.dart';
import 'package:nasyad/presentation/device/device_category_presets.dart';
import 'package:nasyad/presentation/device/schedule_presets.dart';

class DevicePage extends StatelessWidget {
  final String deviceId;

  const DevicePage({super.key, required this.deviceId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);

    return BlocConsumer<DeviceDetailBloc, DeviceDetailState>(
      listener: (context, state) {
        if (state is DeviceDetailArchived) {
          context.go('/');
        } else if (state is DeviceDetailError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        return switch (state) {
          DeviceDetailLoading() || DeviceDetailArchived() => Scaffold(
            appBar: AppBar(title: Text(l10n.deviceDetails)),
            body: const Center(child: CircularProgressIndicator()),
          ),
          DeviceDetailNotFound() => Scaffold(
            appBar: AppBar(title: Text(l10n.deviceDetails)),
            body: Center(child: Text(l10n.noDevicesTitle)),
          ),
          DeviceDetailError(:final message) => Scaffold(
            appBar: AppBar(title: Text(l10n.deviceDetails)),
            body: Center(child: Text(message)),
          ),
          DeviceDetailLoaded(:final summary, :final logs) => Scaffold(
            appBar: AppBar(
              title: Text(l10n.deviceDetails),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
                tooltip: l10n.back,
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.archive_outlined),
                  onPressed: () => context.read<DeviceDetailBloc>().add(
                    const DeviceDetailArchiveRequested(),
                  ),
                  tooltip: l10n.archive,
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => context.push('/device/$deviceId/edit'),
                  tooltip: l10n.edit,
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => context.push('/device/$deviceId/log'),
              tooltip: l10n.addLog,
              child: const Icon(Icons.add),
            ),
            body: AppContent(
              child: ListView(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        categoryPresetIcon(summary.device.categoryPreset),
                        size: 28,
                        color: theme.colorScheme.secondary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              summary.device.name,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            if (summary.device.locationLabel != null &&
                                summary.device.locationLabel!.trim().isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: AppSpacing.xxs,
                                ),
                                child: Text(
                                  summary.device.locationLabel!.trim(),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (summary.device.description != null &&
                      summary.device.description!.trim().isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      summary.device.description!.trim(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.sm),
                  _statusBadge(l10n, summary.status),
                  const SizedBox(height: AppSpacing.md),
                  if (summary.progress > 0 || summary.device.hasSchedule) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: summary.progress.clamp(0.0, 1.0),
                        minHeight: 10,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  SectionHeader(title: l10n.scheduleSection),
                  Card(
                    child: ListTile(
                      title: Text(_scheduleLabel(l10n, summary)),
                      subtitle: summary.device.usageUnit != null
                          ? Text(
                              l10n.currentUsageLabel(
                                summary.device.currentUsage,
                                usageUnitLabel(l10n, summary.device.usageUnit!),
                              ),
                            )
                          : null,
                    ),
                  ),
                  SectionHeader(title: l10n.childrenSection),
                  if (summary.children.isEmpty)
                    Card(
                      child: ListTile(
                        title: Text(l10n.addChild),
                        trailing: const Icon(Icons.add),
                        onTap: () =>
                            context.push('/device/new?parentId=$deviceId'),
                      ),
                    )
                  else ...[
                    for (final child in summary.children)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: DeviceCard(
                          name: child.device.name,
                          label:
                              child.device.locationLabel?.trim().isNotEmpty ==
                                  true
                              ? child.device.locationLabel!.trim()
                              : null,
                          leading: Icon(
                            categoryPresetIcon(child.device.categoryPreset),
                            color: theme.colorScheme.secondary,
                          ),
                          status: _cardStatus(child.status),
                          statusLabel: _statusLabel(l10n, child.status),
                          progress: child.progress,
                          onTap: () =>
                              context.push('/device/${child.device.id}'),
                        ),
                      ),
                    TextButton.icon(
                      onPressed: () =>
                          context.push('/device/new?parentId=$deviceId'),
                      icon: const Icon(Icons.add),
                      label: Text(l10n.addChild),
                    ),
                  ],
                  SectionHeader(title: l10n.logHistory),
                  Card(
                    child: logs.isEmpty
                        ? ListTile(title: Text(l10n.noLogsYet))
                        : Column(
                            children: [
                              for (var i = 0; i < logs.length; i++)
                                LogListItem(
                                  title: _logTitle(
                                    l10n,
                                    logs[i].kind,
                                    logs[i].notes,
                                  ),
                                  subtitle: _logSubtitle(l10n, locale, logs[i]),
                                  leading: LogPhotoThumbnail(
                                    photoPath: logs[i].photoPath,
                                    onTap: logs[i].photoPath == null
                                        ? null
                                        : () => LogPhotoPreviewDialog.show(
                                            context,
                                            logs[i].photoPath!,
                                          ),
                                  ),
                                  showDivider: i != logs.length - 1,
                                ),
                            ],
                          ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        };
      },
    );
  }

  String _scheduleLabel(AppLocalizations l10n, DeviceSummary summary) {
    final device = summary.device;
    if (!device.hasSchedule) return l10n.noScheduleConfigured;
    final value = device.intervalValue;
    final unit = device.intervalUnit;
    if (value == null || unit == null) return l10n.noScheduleConfigured;
    return scheduleDisplayName(l10n: l10n, value: value, unitStorage: unit);
  }

  String _logTitle(AppLocalizations l10n, DeviceLogKind kind, String? notes) {
    if (notes != null && notes.trim().isNotEmpty) return notes.trim();
    return switch (kind) {
      DeviceLogKind.maintenanceDone => l10n.markMaintained,
      DeviceLogKind.usageUpdate => l10n.updateUsage,
    };
  }

  String _logSubtitle(AppLocalizations l10n, Locale locale, DeviceLog log) {
    final parts = <String>[
      DateFormat.yMMMd(locale.toString()).add_jm().format(log.date),
    ];
    if (log.cost != null) {
      parts.add(
        formatLogCost(locale, log.cost!, currencyLabel: log.costCurrency),
      );
    }
    final vendor = log.vendor?.trim();
    if (vendor != null && vendor.isNotEmpty) {
      parts.add(vendor);
    }
    return parts.join(' · ');
  }

  Widget _statusBadge(AppLocalizations l10n, MaintenanceStatus status) {
    return switch (status) {
      MaintenanceStatus.due => StatusBadge.warning(label: l10n.maintenanceDue),
      MaintenanceStatus.soon => StatusBadge(label: l10n.maintenanceSoon),
      MaintenanceStatus.upToDate => StatusBadge.success(label: l10n.upToDate),
    };
  }
}

DeviceMaintenanceStatus _cardStatus(MaintenanceStatus status) {
  return switch (status) {
    MaintenanceStatus.upToDate => DeviceMaintenanceStatus.upToDate,
    MaintenanceStatus.soon => DeviceMaintenanceStatus.soon,
    MaintenanceStatus.due => DeviceMaintenanceStatus.due,
  };
}

String _statusLabel(AppLocalizations l10n, MaintenanceStatus status) {
  return switch (status) {
    MaintenanceStatus.upToDate => l10n.upToDate,
    MaintenanceStatus.soon => l10n.maintenanceSoon,
    MaintenanceStatus.due => l10n.maintenanceDue,
  };
}
