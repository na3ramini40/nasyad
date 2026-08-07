import 'package:flutter/material.dart';

import 'package:nasyad/core/theme/app_spacing.dart';
import 'package:nasyad/core/theme/app_status_colors.dart';

class LogListItem extends StatelessWidget {
  const LogListItem({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.leading,
    this.onTap,
    this.showDivider = true,
  });

  final String title;
  final String? subtitle;
  final String? trailing;
  final Widget? leading;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = AppStatusColors.of(context).muted;

    return Column(
      children: [
        ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xxs,
          ),
          leading: leading,
          title: Text(title, style: theme.textTheme.titleSmall),
          subtitle: subtitle == null
              ? null
              : Text(
                  subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(color: muted),
                ),
          trailing: trailing == null
              ? null
              : Text(
                  trailing!,
                  style: theme.textTheme.bodySmall?.copyWith(color: muted),
                ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: AppSpacing.md,
            endIndent: AppSpacing.md,
            color: theme.colorScheme.outlineVariant,
          ),
      ],
    );
  }
}
