import 'package:flutter/material.dart';

import 'package:nasyad/core/theme/app_spacing.dart';
import 'package:nasyad/core/theme/app_status_colors.dart';

enum StatusBadgeVariant { success, warning, neutral }

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    this.variant = StatusBadgeVariant.neutral,
    this.dense = false,
  });

  const StatusBadge.success({
    super.key,
    required this.label,
    this.dense = false,
  }) : variant = StatusBadgeVariant.success;

  const StatusBadge.warning({
    super.key,
    required this.label,
    this.dense = false,
  }) : variant = StatusBadgeVariant.warning;

  final String label;
  final StatusBadgeVariant variant;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = AppStatusColors.of(context);
    final scheme = theme.colorScheme;

    final (Color bg, Color fg) = switch (variant) {
      StatusBadgeVariant.success => (status.success, status.onSuccess),
      StatusBadgeVariant.warning => (status.warning, status.onWarning),
      StatusBadgeVariant.neutral => (
        scheme.surfaceContainerHighest,
        scheme.onSurfaceVariant,
      ),
    };

    return Semantics(
      label: label,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: dense ? AppSpacing.xs : AppSpacing.sm,
          vertical: dense ? AppSpacing.xxs : 6,
        ),
        decoration: ShapeDecoration(color: bg, shape: const StadiumBorder()),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: fg,
            fontWeight: FontWeight.w600,
            fontSize: dense ? 11 : 12,
          ),
        ),
      ),
    );
  }
}
