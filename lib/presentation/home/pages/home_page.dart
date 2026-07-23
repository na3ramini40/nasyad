import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:nasyad/core/l10n/l10n.dart';
import 'package:nasyad/core/theme/app_breakpoints.dart';
import 'package:nasyad/core/theme/app_spacing.dart';
import 'package:nasyad/core/ui/ui.dart';
import 'package:nasyad/domain/entities/device_log.dart';
import 'package:nasyad/domain/entities/maintenance_status.dart';
import 'package:nasyad/presentation/home/bloc/home_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            onPressed: () => context.push('/preferences'),
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n.preferences,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/device/new'),
        tooltip: l10n.addDevice,
        child: const Icon(Icons.add),
      ),
      body: AppContent(
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            return switch (state) {
              HomeInitial() || HomeLoading() =>
                const Center(child: CircularProgressIndicator()),
              HomeError(:final message) => Center(child: Text(message)),
              HomeLoaded(:final summaries) when summaries.isEmpty =>
                _EmptyDevices(l10n: l10n),
              HomeLoaded(:final summaries) => ResponsiveBuilder(
                  builder: (context, windowSize) {
                    final columns =
                        AppBreakpoints.deviceGridColumns(windowSize);
                    final useGrid = columns > 1;

                    if (!useGrid) {
                      return ListView.separated(
                        itemCount: summaries.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSpacing.md),
                        itemBuilder: (context, index) {
                          final item = summaries[index];
                          return DeviceCard(
                            name: item.device.name,
                            label: l10n.deviceName,
                            status: _cardStatus(item.status),
                            statusLabel: _statusLabel(l10n, item.status),
                            lastLogText: _lastLogText(l10n, item.latestLog),
                            onTap: () =>
                                context.push('/device/${item.device.id}'),
                          );
                        },
                      );
                    }

                    return GridView.builder(
                      itemCount: summaries.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        mainAxisSpacing: AppSpacing.md,
                        crossAxisSpacing: AppSpacing.md,
                        childAspectRatio: 1.25,
                      ),
                      itemBuilder: (context, index) {
                        final item = summaries[index];
                        return DeviceCard(
                          name: item.device.name,
                          label: l10n.deviceName,
                          status: _cardStatus(item.status),
                          statusLabel: _statusLabel(l10n, item.status),
                          lastLogText: _lastLogText(l10n, item.latestLog),
                          variant: DeviceCardVariant.grid,
                          progress: item.progress,
                          leading: Icon(
                            Icons.devices_other,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          onTap: () =>
                              context.push('/device/${item.device.id}'),
                        );
                      },
                    );
                  },
                ),
            };
          },
        ),
      ),
    );
  }
}

class _EmptyDevices extends StatelessWidget {
  const _EmptyDevices({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.devices_other_outlined,
              size: 48,
              color: theme.colorScheme.secondary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.noDevicesTitle,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.noDevicesHint,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
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

String? _lastLogText(AppLocalizations l10n, DeviceLog? log) {
  if (log == null) return l10n.lastLog(l10n.noLogsYet);
  final diff = DateTime.now().difference(log.date);
  final value = diff.inMinutes < 60
      ? l10n.lastLogMinutesAgo(diff.inMinutes.clamp(1, 59))
      : diff.inDays < 7
          ? l10n.lastLogDaysAgo(diff.inDays.clamp(1, 6))
          : l10n.lastLogWeeksAgo((diff.inDays / 7).floor().clamp(1, 999));
  return l10n.lastLog(value);
}
