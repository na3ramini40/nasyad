import 'package:flutter/material.dart';

import 'package:nasyad/core/theme/app_radius.dart';
import 'package:nasyad/core/theme/app_spacing.dart';

class SelectableOptionTile extends StatelessWidget {
  const SelectableOptionTile({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.trailing,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final bg = selected
        ? scheme.secondary.withValues(alpha: 0.12)
        : scheme.surfaceContainerHighest.withValues(alpha: 0.45);

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: bg,
        borderRadius: AppRadius.borderMd,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.borderMd,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      color: scheme.onSurface,
                    ),
                  ),
                ),
                if (trailing != null) trailing!,
                if (selected)
                  Icon(Icons.check, color: scheme.secondary, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
