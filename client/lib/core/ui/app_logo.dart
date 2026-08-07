import 'package:flutter/material.dart';
import 'package:nasyad/core/theme/app_assets.dart';

enum AppLogoVariant { full, wordmark, mark }

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.height = 40,
    this.variant = AppLogoVariant.wordmark,
    this.semanticLabel = 'nasyad',
  });

  const AppLogo.mark({
    super.key,
    this.height = 28,
    this.semanticLabel = 'nasyad',
  }) : variant = AppLogoVariant.mark;

  const AppLogo.full({
    super.key,
    this.height = 120,
    this.semanticLabel = 'nasyad',
  }) : variant = AppLogoVariant.full;

  final double height;
  final AppLogoVariant variant;
  final String? semanticLabel;

  String get _asset => switch (variant) {
    AppLogoVariant.full => AppAssets.logo,
    AppLogoVariant.wordmark => AppAssets.logoWordmark,
    AppLogoVariant.mark => AppAssets.logoMark,
  };

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _asset,
      height: height,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      semanticLabel: semanticLabel,
    );
  }
}
