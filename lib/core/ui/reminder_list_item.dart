import 'package:flutter/material.dart';

import 'package:nasyad/core/theme/app_radius.dart';
import 'package:nasyad/core/theme/app_spacing.dart';
import 'package:nasyad/core/ui/status_badge.dart';

class ReminderListItem extends StatelessWidget {
  const ReminderListItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.badgeLabel,
    required this.icon,
    this.badgeVariant = StatusBadgeVariant.neutral,
    this.onTap,
    this.onQuickActions,
    this.quickActionsTooltip,
    this.onSnooze,
    this.snoozeTooltip,
  });

  final String title;
  final String subtitle;
  final String badgeLabel;
  final IconData icon;
  final StatusBadgeVariant badgeVariant;
  final VoidCallback? onTap;
  final VoidCallback? onQuickActions;
  final String? quickActionsTooltip;
  final VoidCallback? onSnooze;
  final String? snoozeTooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Expanded(
              child: Semantics(
                button: onTap != null,
                label: '$title. $subtitle',
                child: InkWell(
                  onTap: onTap,
                  borderRadius: AppRadius.borderMd,
                  child: Row(
                    children: [
                      Icon(icon, color: scheme.secondary),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: theme.textTheme.titleSmall),
                            const SizedBox(height: AppSpacing.xxs),
                            Text(
                              subtitle,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (onSnooze != null) ...[
              IconButton(
                onPressed: onSnooze,
                icon: const Icon(Icons.snooze_outlined),
                tooltip: snoozeTooltip,
                visualDensity: VisualDensity.compact,
              ),
            ],
            if (onQuickActions != null) ...[
              IconButton(
                onPressed: onQuickActions,
                icon: const Icon(Icons.more_vert),
                tooltip: quickActionsTooltip,
              ),
            ],
            const SizedBox(width: AppSpacing.sm),
            StatusBadge(label: badgeLabel, variant: badgeVariant),
          ],
        ),
      ),
    );
  }
}
