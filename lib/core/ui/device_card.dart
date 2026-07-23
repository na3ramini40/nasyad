import 'package:flutter/material.dart';

import 'package:nasyad/core/theme/app_radius.dart';
import 'package:nasyad/core/theme/app_spacing.dart';
import 'package:nasyad/core/theme/app_status_colors.dart';
import 'package:nasyad/core/ui/status_badge.dart';

enum DeviceCardVariant { list, grid }

enum DeviceMaintenanceStatus { upToDate, soon, due }

class DeviceCard extends StatelessWidget {
  const DeviceCard({
    super.key,
    required this.name,
    this.label,
    this.lastLogText,
    this.status,
    this.statusLabel,
    this.leading,
    this.progress,
    this.selected = false,
    this.variant = DeviceCardVariant.list,
    this.onTap,
    this.onMenuPressed,
  });

  final String name;
  final String? label;
  final String? lastLogText;
  final DeviceMaintenanceStatus? status;
  final String? statusLabel;
  final Widget? leading;
  final double? progress;
  final bool selected;
  final DeviceCardVariant variant;
  final VoidCallback? onTap;
  final VoidCallback? onMenuPressed;

  @override
  Widget build(BuildContext context) {
    return switch (variant) {
      DeviceCardVariant.list => _ListDeviceCard(this),
      DeviceCardVariant.grid => _GridDeviceCard(this),
    };
  }
}

class _ListDeviceCard extends StatelessWidget {
  const _ListDeviceCard(this.data);

  final DeviceCard data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final status = AppStatusColors.of(context);

    final Color? tint = data.selected
        ? scheme.secondary.withValues(alpha: 0.12)
        : null;

    return Card(
      color: tint ?? scheme.surface,
      child: InkWell(
        onTap: data.onTap,
        borderRadius: AppRadius.borderLg,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (data.leading != null) ...[
                data.leading!,
                const SizedBox(width: AppSpacing.sm),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (data.label != null) ...[
                      Text(
                        data.label!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: status.muted,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                    ],
                    Text(
                      data.name,
                      style: theme.textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (data.status != null || data.statusLabel != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      _statusBadge(data),
                    ],
                    if (data.lastLogText != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        data.lastLogText!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: status.muted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (data.onMenuPressed != null)
                IconButton(
                  onPressed: data.onMenuPressed,
                  icon: const Icon(Icons.more_vert),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GridDeviceCard extends StatelessWidget {
  const _GridDeviceCard(this.data);

  final DeviceCard data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final status = AppStatusColors.of(context);
    final progress = data.progress?.clamp(0.0, 1.0);

    return Card(
      child: InkWell(
        onTap: data.onTap,
        borderRadius: AppRadius.borderLg,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  data.leading ??
                      Icon(Icons.devices_other, color: scheme.secondary),
                  const Spacer(),
                  if (progress != null)
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 3,
                            backgroundColor: scheme.outlineVariant.withValues(
                              alpha: 0.5,
                            ),
                          ),
                          Text(
                            '${(progress * 100).round()}%',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: scheme.secondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const Spacer(),
              Text(
                data.name,
                style: theme.textTheme.titleMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (data.status != null || data.statusLabel != null) ...[
                const SizedBox(height: AppSpacing.xs),
                _statusBadge(data),
              ],
              if (data.lastLogText != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  data.lastLogText!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: status.muted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

Widget _statusBadge(DeviceCard data) {
  final label = data.statusLabel;
  if (label == null || label.isEmpty) {
    return const SizedBox.shrink();
  }
  if (data.status == DeviceMaintenanceStatus.due) {
    return StatusBadge.warning(label: label);
  }
  if (data.status == DeviceMaintenanceStatus.soon) {
    return StatusBadge(label: label);
  }
  if (data.status == DeviceMaintenanceStatus.upToDate) {
    return StatusBadge.success(label: label);
  }
  return StatusBadge(label: label);
}
