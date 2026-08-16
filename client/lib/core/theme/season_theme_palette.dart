import 'package:flutter/material.dart';

import 'package:nasyad/core/theme/app_colors.dart';
import 'package:nasyad/core/theme/app_status_colors.dart';
import 'package:nasyad/domain/entities/season_theme.dart';

@immutable
class SeasonThemePalette {
  const SeasonThemePalette({
    required this.primary,
    required this.onPrimary,
    required this.secondary,
    required this.onSecondary,
    required this.error,
    required this.onError,
    required this.surface,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.outline,
    required this.outlineVariant,
    required this.scaffoldBackground,
    required this.statusColors,
    required this.cardElevation,
    required this.shadowColor,
  });

  final Color primary;
  final Color onPrimary;
  final Color secondary;
  final Color onSecondary;
  final Color error;
  final Color onError;
  final Color surface;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color outline;
  final Color outlineVariant;
  final Color scaffoldBackground;
  final AppStatusColors statusColors;
  final double cardElevation;
  final Color shadowColor;

  static SeasonThemePalette forSeason(
    SeasonTheme season,
    Brightness brightness,
  ) {
    return switch ((season, brightness)) {
      (SeasonTheme.classic, Brightness.light) => classicLight,
      (SeasonTheme.classic, Brightness.dark) => classicDark,
      (SeasonTheme.spring, Brightness.light) => springLight,
      (SeasonTheme.spring, Brightness.dark) => springDark,
      (SeasonTheme.summer, Brightness.light) => summerLight,
      (SeasonTheme.summer, Brightness.dark) => summerDark,
      (SeasonTheme.autumn, Brightness.light) => autumnLight,
      (SeasonTheme.autumn, Brightness.dark) => autumnDark,
      (SeasonTheme.winter, Brightness.light) => winterLight,
      (SeasonTheme.winter, Brightness.dark) => winterDark,
      (SeasonTheme.colorBlind, Brightness.light) => colorBlindLight,
      (SeasonTheme.colorBlind, Brightness.dark) => colorBlindDark,
    };
  }

  static const classicLight = SeasonThemePalette(
    primary: AppColors.primary,
    onPrimary: Colors.white,
    secondary: AppColors.secondary,
    onSecondary: Colors.white,
    error: AppColors.error,
    onError: Colors.white,
    surface: AppColors.surfaceLight,
    onSurface: AppColors.brandInk,
    onSurfaceVariant: AppColors.onSurfaceMutedLight,
    outline: Color(0xFFD1D5DB),
    outlineVariant: Color(0xFFE5E7EB),
    scaffoldBackground: AppColors.backgroundLight,
    statusColors: AppStatusColors.light,
    cardElevation: 1.5,
    shadowColor: Color(0x14000000),
  );

  static const classicDark = SeasonThemePalette(
    primary: AppColors.primary,
    onPrimary: Colors.white,
    secondary: AppColors.secondaryDark,
    onSecondary: Color(0xFF003910),
    error: AppColors.errorDark,
    onError: Color(0xFF3E0000),
    surface: AppColors.surfaceDark,
    onSurface: Color(0xFFE8EAED),
    onSurfaceVariant: AppColors.onSurfaceMutedDark,
    outline: Color(0xFF3F3F46),
    outlineVariant: Color(0xFF2A2A2E),
    scaffoldBackground: AppColors.backgroundDark,
    statusColors: AppStatusColors.dark,
    cardElevation: 0,
    shadowColor: Colors.transparent,
  );

  static const springLight = SeasonThemePalette(
    primary: Color(0xFF2E7D5A),
    onPrimary: Colors.white,
    secondary: Color(0xFFE891A8),
    onSecondary: Color(0xFF4A1A2A),
    error: Color(0xFFC62828),
    onError: Colors.white,
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF1B3A2A),
    onSurfaceVariant: Color(0xFF5C7268),
    outline: Color(0xFFB8D4C4),
    outlineVariant: Color(0xFFDCEFE4),
    scaffoldBackground: Color(0xFFF4FBF6),
    statusColors: AppStatusColors(
      success: Color(0xFF2E7D32),
      onSuccess: Colors.white,
      successContainer: Color(0xFFE0F2E9),
      onSuccessContainer: Color(0xFF1B5E20),
      warning: Color(0xFFC62828),
      onWarning: Colors.white,
      warningContainer: Color(0xFFFFEBEE),
      onWarningContainer: Color(0xFFB71C1C),
      muted: Color(0xFF5C7268),
    ),
    cardElevation: 1.5,
    shadowColor: Color(0x14000000),
  );

  static const springDark = SeasonThemePalette(
    primary: Color(0xFF5DC996),
    onPrimary: Color(0xFF0A2818),
    secondary: Color(0xFFF4A6BC),
    onSecondary: Color(0xFF3E1020),
    error: Color(0xFFEF5350),
    onError: Color(0xFF3E0000),
    surface: Color(0xFF1A2820),
    onSurface: Color(0xFFE4F2EA),
    onSurfaceVariant: Color(0xFF9BB8AA),
    outline: Color(0xFF3A5248),
    outlineVariant: Color(0xFF2A3A32),
    scaffoldBackground: Color(0xFF0F1A14),
    statusColors: AppStatusColors(
      success: Color(0xFF69F0AE),
      onSuccess: Color(0xFF00382A),
      successContainer: Color(0xFF1B3A2F),
      onSuccessContainer: Color(0xFFB9F6CA),
      warning: Color(0xFFEF5350),
      onWarning: Color(0xFF3E0000),
      warningContainer: Color(0xFF3E1A1A),
      onWarningContainer: Color(0xFFFFCDD2),
      muted: Color(0xFF9BB8AA),
    ),
    cardElevation: 0,
    shadowColor: Colors.transparent,
  );

  static const summerLight = SeasonThemePalette(
    primary: Color(0xFFE8920A),
    onPrimary: Color(0xFF3E2200),
    secondary: Color(0xFF1E88C4),
    onSecondary: Colors.white,
    error: Color(0xFFD32F2F),
    onError: Colors.white,
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF3E2800),
    onSurfaceVariant: Color(0xFF7A6040),
    outline: Color(0xFFE8D4A8),
    outlineVariant: Color(0xFFF5ECD8),
    scaffoldBackground: Color(0xFFFFFBF0),
    statusColors: AppStatusColors(
      success: Color(0xFF558B2F),
      onSuccess: Colors.white,
      successContainer: Color(0xFFF1F8E9),
      onSuccessContainer: Color(0xFF33691E),
      warning: Color(0xFFD32F2F),
      onWarning: Colors.white,
      warningContainer: Color(0xFFFFEBEE),
      onWarningContainer: Color(0xFFB71C1C),
      muted: Color(0xFF7A6040),
    ),
    cardElevation: 1.5,
    shadowColor: Color(0x14000000),
  );

  static const summerDark = SeasonThemePalette(
    primary: Color(0xFFFFB74D),
    onPrimary: Color(0xFF3E2200),
    secondary: Color(0xFF4FC3F7),
    onSecondary: Color(0xFF003044),
    error: Color(0xFFEF5350),
    onError: Color(0xFF3E0000),
    surface: Color(0xFF2A2210),
    onSurface: Color(0xFFFFF3E0),
    onSurfaceVariant: Color(0xFFB8A080),
    outline: Color(0xFF5A4830),
    outlineVariant: Color(0xFF3A3020),
    scaffoldBackground: Color(0xFF1A1408),
    statusColors: AppStatusColors(
      success: Color(0xFFAED581),
      onSuccess: Color(0xFF1B3A00),
      successContainer: Color(0xFF2E4A1A),
      onSuccessContainer: Color(0xFFDCEDC8),
      warning: Color(0xFFEF5350),
      onWarning: Color(0xFF3E0000),
      warningContainer: Color(0xFF3E1A1A),
      onWarningContainer: Color(0xFFFFCDD2),
      muted: Color(0xFFB8A080),
    ),
    cardElevation: 0,
    shadowColor: Colors.transparent,
  );

  static const autumnLight = SeasonThemePalette(
    primary: Color(0xFFC45C26),
    onPrimary: Colors.white,
    secondary: Color(0xFF8B6914),
    onSecondary: Colors.white,
    error: Color(0xFFC62828),
    onError: Colors.white,
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF3E2010),
    onSurfaceVariant: Color(0xFF7A5A40),
    outline: Color(0xFFD4B898),
    outlineVariant: Color(0xFFEDE0D0),
    scaffoldBackground: Color(0xFFFBF6F0),
    statusColors: AppStatusColors(
      success: Color(0xFF558B2F),
      onSuccess: Colors.white,
      successContainer: Color(0xFFF1F8E9),
      onSuccessContainer: Color(0xFF33691E),
      warning: Color(0xFFC62828),
      onWarning: Colors.white,
      warningContainer: Color(0xFFFFEBEE),
      onWarningContainer: Color(0xFFB71C1C),
      muted: Color(0xFF7A5A40),
    ),
    cardElevation: 1.5,
    shadowColor: Color(0x14000000),
  );

  static const autumnDark = SeasonThemePalette(
    primary: Color(0xFFE07840),
    onPrimary: Color(0xFF3E1800),
    secondary: Color(0xFFD4A843),
    onSecondary: Color(0xFF3E2800),
    error: Color(0xFFEF5350),
    onError: Color(0xFF3E0000),
    surface: Color(0xFF2A1E10),
    onSurface: Color(0xFFFFF0E0),
    onSurfaceVariant: Color(0xFFB89878),
    outline: Color(0xFF5A4030),
    outlineVariant: Color(0xFF3A2A20),
    scaffoldBackground: Color(0xFF1A1208),
    statusColors: AppStatusColors(
      success: Color(0xFFAED581),
      onSuccess: Color(0xFF1B3A00),
      successContainer: Color(0xFF2E4A1A),
      onSuccessContainer: Color(0xFFDCEDC8),
      warning: Color(0xFFEF5350),
      onWarning: Color(0xFF3E0000),
      warningContainer: Color(0xFF3E1A1A),
      onWarningContainer: Color(0xFFFFCDD2),
      muted: Color(0xFFB89878),
    ),
    cardElevation: 0,
    shadowColor: Colors.transparent,
  );

  static const winterLight = SeasonThemePalette(
    primary: Color(0xFF3A6EA5),
    onPrimary: Colors.white,
    secondary: Color(0xFF7BA7BC),
    onSecondary: Color(0xFF102030),
    error: Color(0xFFC62828),
    onError: Colors.white,
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF1A2840),
    onSurfaceVariant: Color(0xFF5A7088),
    outline: Color(0xFFB8C8D8),
    outlineVariant: Color(0xFFDCE8F0),
    scaffoldBackground: Color(0xFFF0F4F8),
    statusColors: AppStatusColors(
      success: Color(0xFF2E7D32),
      onSuccess: Colors.white,
      successContainer: Color(0xFFE3F2FD),
      onSuccessContainer: Color(0xFF1B5E20),
      warning: Color(0xFFC62828),
      onWarning: Colors.white,
      warningContainer: Color(0xFFFFEBEE),
      onWarningContainer: Color(0xFFB71C1C),
      muted: Color(0xFF5A7088),
    ),
    cardElevation: 1.5,
    shadowColor: Color(0x14000000),
  );

  static const winterDark = SeasonThemePalette(
    primary: Color(0xFF6BA3D6),
    onPrimary: Color(0xFF0A1828),
    secondary: Color(0xFFA8C8DC),
    onSecondary: Color(0xFF102030),
    error: Color(0xFFEF5350),
    onError: Color(0xFF3E0000),
    surface: Color(0xFF1A2030),
    onSurface: Color(0xFFE0EAF4),
    onSurfaceVariant: Color(0xFF90A8C0),
    outline: Color(0xFF3A4860),
    outlineVariant: Color(0xFF2A3040),
    scaffoldBackground: Color(0xFF0E1218),
    statusColors: AppStatusColors(
      success: Color(0xFF69F0AE),
      onSuccess: Color(0xFF00382A),
      successContainer: Color(0xFF1A3040),
      onSuccessContainer: Color(0xFFB9F6CA),
      warning: Color(0xFFEF5350),
      onWarning: Color(0xFF3E0000),
      warningContainer: Color(0xFF3E1A1A),
      onWarningContainer: Color(0xFFFFCDD2),
      muted: Color(0xFF90A8C0),
    ),
    cardElevation: 0,
    shadowColor: Colors.transparent,
  );

  static const colorBlindLight = SeasonThemePalette(
    primary: Color(0xFF1565C0),
    onPrimary: Colors.white,
    secondary: Color(0xFFE65100),
    onSecondary: Colors.white,
    error: Color(0xFF6A1B9A),
    onError: Colors.white,
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF0D1B2A),
    onSurfaceVariant: Color(0xFF4A5568),
    outline: Color(0xFFB0BEC5),
    outlineVariant: Color(0xFFE0E7EC),
    scaffoldBackground: Color(0xFFF5F8FB),
    statusColors: AppStatusColors(
      success: Color(0xFF0277BD),
      onSuccess: Colors.white,
      successContainer: Color(0xFFE1F5FE),
      onSuccessContainer: Color(0xFF01579B),
      warning: Color(0xFFEF6C00),
      onWarning: Colors.white,
      warningContainer: Color(0xFFFFF3E0),
      onWarningContainer: Color(0xFFE65100),
      muted: Color(0xFF546E7A),
    ),
    cardElevation: 1.5,
    shadowColor: Color(0x14000000),
  );

  static const colorBlindDark = SeasonThemePalette(
    primary: Color(0xFF64B5F6),
    onPrimary: Color(0xFF002F54),
    secondary: Color(0xFFFFB74D),
    onSecondary: Color(0xFF3E2200),
    error: Color(0xFFCE93D8),
    onError: Color(0xFF2A0038),
    surface: Color(0xFF1A2332),
    onSurface: Color(0xFFE8EEF4),
    onSurfaceVariant: Color(0xFF9AA8B8),
    outline: Color(0xFF3D4F63),
    outlineVariant: Color(0xFF2A3544),
    scaffoldBackground: Color(0xFF0D1218),
    statusColors: AppStatusColors(
      success: Color(0xFF4FC3F7),
      onSuccess: Color(0xFF003044),
      successContainer: Color(0xFF0D3A52),
      onSuccessContainer: Color(0xFFB3E5FC),
      warning: Color(0xFFFFB74D),
      onWarning: Color(0xFF3E2200),
      warningContainer: Color(0xFF4A2C00),
      onWarningContainer: Color(0xFFFFE0B2),
      muted: Color(0xFF90A4AE),
    ),
    cardElevation: 0,
    shadowColor: Colors.transparent,
  );
}
