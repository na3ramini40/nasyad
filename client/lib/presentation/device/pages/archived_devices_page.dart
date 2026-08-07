import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:nasyad/core/l10n/l10n.dart';
import 'package:nasyad/core/theme/app_spacing.dart';
import 'package:nasyad/core/ui/ui.dart';
import 'package:nasyad/domain/entities/device.dart';
import 'package:nasyad/presentation/device/bloc/archived_devices_bloc.dart';

class ArchivedDevicesPage extends StatelessWidget {
  const ArchivedDevicesPage({super.key});

  Future<void> _confirmRestore(BuildContext context, Device device) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.restoreDeviceTitle),
          content: Text(l10n.restoreDeviceBody(device.name)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.restore),
            ),
          ],
        );
      },
    );
    if (confirmed == true && context.mounted) {
      context.read<ArchivedDevicesBloc>().add(
        ArchivedDevicesRestoreRequested(device.id),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
          tooltip: l10n.back,
        ),
        title: Text(l10n.archivedDevices),
      ),
      body: AppContent(
        child: BlocConsumer<ArchivedDevicesBloc, ArchivedDevicesState>(
          listenWhen: (previous, current) =>
              current is ArchivedDevicesRestoreFailed,
          buildWhen: (previous, current) =>
              current is! ArchivedDevicesRestoreFailed,
          listener: (context, state) {
            if (state is ArchivedDevicesRestoreFailed) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            return switch (state) {
              ArchivedDevicesInitial() || ArchivedDevicesLoading() =>
                const Center(child: CircularProgressIndicator()),
              ArchivedDevicesError(:final message) => Center(
                child: Text(message),
              ),
              ArchivedDevicesLoaded(:final devices) when devices.isEmpty =>
                _EmptyArchived(l10n: l10n),
              ArchivedDevicesLoaded(:final devices) => _DeviceList(
                devices: devices,
                l10n: l10n,
                onRestore: (device) => _confirmRestore(context, device),
              ),
              ArchivedDevicesRestoreFailed() => const SizedBox.shrink(),
            };
          },
        ),
      ),
    );
  }
}

class _DeviceList extends StatelessWidget {
  const _DeviceList({
    required this.devices,
    required this.l10n,
    required this.onRestore,
  });

  final List<Device> devices;
  final AppLocalizations l10n;
  final void Function(Device device) onRestore;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: devices.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final device = devices[index];
        return Card(
          child: ListTile(
            leading: Icon(
              Icons.archive_outlined,
              color: Theme.of(context).colorScheme.secondary,
            ),
            title: Text(device.name),
            trailing: TextButton(
              onPressed: () => onRestore(device),
              child: Text(l10n.restore),
            ),
          ),
        );
      },
    );
  }
}

class _EmptyArchived extends StatelessWidget {
  const _EmptyArchived({required this.l10n});

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
              Icons.archive_outlined,
              size: 56,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.noArchivedDevicesTitle,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.noArchivedDevicesHint,
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
