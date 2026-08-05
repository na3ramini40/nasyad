import 'package:flutter/material.dart';

import 'package:nasyad/core/theme/season_theme_palette.dart';
import 'package:nasyad/domain/entities/season_theme.dart';

class SeasonThemeSwatch extends StatelessWidget {
  const SeasonThemeSwatch({
    super.key,
    required this.season,
    this.brightness = Brightness.light,
  });

  final SeasonTheme season;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    final palette = SeasonThemePalette.forSeason(season, brightness);
    const size = 14.0;
    const gap = 4.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Dot(color: palette.primary, size: size),
        const SizedBox(width: gap),
        _Dot(color: palette.secondary, size: size),
        const SizedBox(width: gap),
        _Dot(color: palette.scaffoldBackground, size: size, bordered: true),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color, required this.size, this.bordered = false});

  final Color color;
  final double size;
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: bordered
            ? Border.all(color: Theme.of(context).colorScheme.outline, width: 1)
            : null,
      ),
    );
  }
}
