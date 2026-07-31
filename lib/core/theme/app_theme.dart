import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:nasyad/core/theme/app_colors.dart';
import 'package:nasyad/core/theme/app_radius.dart';
import 'package:nasyad/core/theme/app_spacing.dart';
import 'package:nasyad/core/theme/app_status_colors.dart';

abstract final class AppTheme {
  static ThemeData lightTheme({String? fontFamily}) => _build(
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
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
    ),
    scaffoldBackground: AppColors.backgroundLight,
    statusColors: AppStatusColors.light,
    cardElevation: 1.5,
    shadowColor: Colors.black.withValues(alpha: 0.08),
    fontFamily: fontFamily,
  );

  static ThemeData darkTheme({String? fontFamily}) => _build(
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
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
    ),
    scaffoldBackground: AppColors.backgroundDark,
    statusColors: AppStatusColors.dark,
    cardElevation: 0,
    shadowColor: Colors.transparent,
    fontFamily: fontFamily,
  );

  static ThemeData _build({
    required Brightness brightness,
    required ColorScheme colorScheme,
    required Color scaffoldBackground,
    required AppStatusColors statusColors,
    required double cardElevation,
    required Color shadowColor,
    String? fontFamily,
  }) {
    final isDark = brightness == Brightness.dark;
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackground,
      fontFamily: fontFamily,
      extensions: [statusColors],
    );

    final textTheme = _textTheme(colorScheme, fontFamily: fontFamily);

    return base.copyWith(
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.light,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: colorScheme.onPrimary,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
        actionsIconTheme: IconThemeData(color: colorScheme.onPrimary),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: cardElevation,
        shadowColor: shadowColor,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderLg),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.secondary,
        foregroundColor: colorScheme.onSecondary,
        elevation: 4,
        shape: const CircleBorder(),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: colorScheme.secondary,
          foregroundColor: colorScheme.onSecondary,
          disabledBackgroundColor: colorScheme.onSurface.withValues(
            alpha: 0.12,
          ),
          disabledForegroundColor: colorScheme.onSurface.withValues(
            alpha: 0.38,
          ),
          minimumSize: const Size.fromHeight(AppSpacing.minTapTarget),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          minimumSize: const Size.fromHeight(AppSpacing.minTapTarget),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          side: BorderSide(color: colorScheme.outline),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.secondary,
          minimumSize: const Size(
            AppSpacing.minTapTarget,
            AppSpacing.minTapTarget,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.borderMd,
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderMd,
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderMd,
          borderSide: BorderSide(color: colorScheme.secondary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderMd,
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderMd,
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      chipTheme: ChipThemeData(
        shape: const StadiumBorder(),
        side: BorderSide.none,
        labelStyle: textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xxs,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: colorScheme.onSurfaceVariant,
        textColor: colorScheme.onSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
        ),
        showDragHandle: true,
        dragHandleColor: colorScheme.outline,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderLg),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onInverseSurface,
        ),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.secondary,
      ),
      iconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
    );
  }

  static TextTheme _textTheme(ColorScheme scheme, {String? fontFamily}) {
    TextStyle style({
      required double fontSize,
      required FontWeight fontWeight,
      required double height,
      required Color color,
    }) {
      return TextStyle(
        fontFamily: fontFamily,
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: height,
        color: color,
      );
    }

    return TextTheme(
      displayLarge: style(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: scheme.onSurface,
      ),
      headlineLarge: style(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.25,
        color: scheme.onSurface,
      ),
      headlineMedium: style(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: scheme.onSurface,
      ),
      titleLarge: style(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: scheme.onSurface,
      ),
      titleMedium: style(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.35,
        color: scheme.onSurface,
      ),
      titleSmall: style(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.35,
        color: scheme.onSurface,
      ),
      bodyLarge: style(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: scheme.onSurface,
      ),
      bodyMedium: style(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: scheme.onSurface,
      ),
      bodySmall: style(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: scheme.onSurfaceVariant,
      ),
      labelLarge: style(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: scheme.onSurface,
      ),
      labelMedium: style(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: scheme.onSurface,
      ),
      labelSmall: style(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 1.3,
        color: scheme.onSurfaceVariant,
      ),
    );
  }
}
