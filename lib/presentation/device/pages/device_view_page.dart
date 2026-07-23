import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:nasyad/core/l10n/l10n.dart';
import 'package:nasyad/core/theme/app_spacing.dart';
import 'package:nasyad/core/ui/ui.dart';
import 'package:nasyad/domain/entities/maintenance_status.dart';
import 'package:nasyad/presentation/device/bloc/device_detail_bloc.dart';

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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
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
                    onPressed: () => context
                        .read<DeviceDetailBloc>()
                        .add(const DeviceDetailArchiveRequested()),
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
                    Text(
                      summary.device.name,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _statusBadge(l10n, summary.status),
                    SectionHeader(title: l10n.activeMaintenanceRules),
                    Card(
                      child: summary.rules.isEmpty
                          ? ListTile(title: Text(l10n.selectMaintenanceRule))
                          : Column(
                              children: [
                                for (var i = 0;
                                    i < summary.rules.length;
                                    i++) ...[
                                  ListTile(title: Text(summary.rules[i].name)),
                                  if (i != summary.rules.length - 1)
                                    const Divider(height: 1),
                                ],
                              ],
                            ),
                    ),
                    SectionHeader(title: l10n.logHistory),
                    Card(
                      child: logs.isEmpty
                          ? ListTile(title: Text(l10n.noLogsYet))
                          : Column(
                              children: [
                                for (var i = 0; i < logs.length; i++)
                                  LogListItem(
                                    title: logs[i].notes?.trim().isNotEmpty ==
                                            true
                                        ? logs[i].notes!.trim()
                                        : l10n.addLog,
                                    subtitle: DateFormat.yMMMd(
                                      locale.toString(),
                                    ).add_jm().format(logs[i].date),
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

  Widget _statusBadge(AppLocalizations l10n, MaintenanceStatus status) {
    return switch (status) {
      MaintenanceStatus.due => StatusBadge.warning(label: l10n.maintenanceDue),
      MaintenanceStatus.soon => StatusBadge(label: l10n.maintenanceSoon),
      MaintenanceStatus.upToDate => StatusBadge.success(label: l10n.upToDate),
    };
  }
}
