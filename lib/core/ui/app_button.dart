import 'package:flutter/material.dart';

import 'package:nasyad/core/theme/app_spacing.dart';

enum AppButtonVariant { primary, secondary, tonal, danger }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.expand = true,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool expand;
  final bool isLoading;

  bool get _enabled => onPressed != null && !isLoading;

  @override
  Widget build(BuildContext context) {
    final child = _ButtonContent(
      label: label,
      icon: icon,
      isLoading: isLoading,
    );

    final button = switch (variant) {
      AppButtonVariant.primary => ElevatedButton(
          onPressed: _enabled ? onPressed : null,
          child: child,
        ),
      AppButtonVariant.secondary => OutlinedButton(
          onPressed: _enabled ? onPressed : null,
          child: child,
        ),
      AppButtonVariant.tonal => FilledButton.tonal(
          onPressed: _enabled ? onPressed : null,
          child: child,
        ),
      AppButtonVariant.danger => ElevatedButton(
          onPressed: _enabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          ),
          child: child,
        ),
    };

    if (!expand) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.label,
    required this.icon,
    required this.isLoading,
  });

  final String label;
  final IconData? icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (icon == null) return Text(label);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: AppSpacing.xs),
        Text(label),
      ],
    );
  }
}
