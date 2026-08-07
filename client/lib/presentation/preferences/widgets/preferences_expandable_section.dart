import 'package:flutter/material.dart';

import 'package:nasyad/core/theme/app_spacing.dart';

/// Preferences category that expands/collapses like Material [ExpansionTile],
/// visually aligned with existing Card + SectionHeader sections.
class PreferencesExpandableSection extends StatelessWidget {
  const PreferencesExpandableSection({
    super.key,
    required this.title,
    required this.children,
    this.initiallyExpanded = false,
    this.subtitle,
    this.leading,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget> children;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(top: AppSpacing.md),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          leading: leading,
          title: Text(title, style: theme.textTheme.titleMedium),
          subtitle: subtitle == null
              ? null
              : Text(subtitle!, style: theme.textTheme.bodySmall),
          childrenPadding: EdgeInsets.zero,
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) const Divider(height: 1),
              children[i],
            ],
          ],
        ),
      ),
    );
  }
}
