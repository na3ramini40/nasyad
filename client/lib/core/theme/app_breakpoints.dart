import 'package:flutter/widgets.dart';

enum AppWindowSize { compact, medium, expanded, large }

abstract final class AppBreakpoints {
  static const double compact = 600;
  static const double medium = 1024;
  static const double expanded = 1440;

  static AppWindowSize ofWidth(double width) {
    if (width < compact) return AppWindowSize.compact;
    if (width < medium) return AppWindowSize.medium;
    if (width < expanded) return AppWindowSize.expanded;
    return AppWindowSize.large;
  }

  static AppWindowSize of(BuildContext context) {
    return ofWidth(MediaQuery.sizeOf(context).width);
  }

  static bool isCompact(BuildContext context) =>
      of(context) == AppWindowSize.compact;

  static bool isMediumUp(BuildContext context) =>
      of(context).index >= AppWindowSize.medium.index;

  static bool isExpandedUp(BuildContext context) =>
      of(context).index >= AppWindowSize.expanded.index;

  static int deviceGridColumns(AppWindowSize size) {
    return switch (size) {
      AppWindowSize.compact => 1,
      AppWindowSize.medium => 2,
      AppWindowSize.expanded => 3,
      AppWindowSize.large => 4,
    };
  }

  static double contentMaxWidth(AppWindowSize size) {
    return switch (size) {
      AppWindowSize.compact => double.infinity,
      AppWindowSize.medium => 840,
      AppWindowSize.expanded => 1100,
      AppWindowSize.large => 1400,
    };
  }

  static double pagePadding(AppWindowSize size) {
    return switch (size) {
      AppWindowSize.compact => 16,
      AppWindowSize.medium => 24,
      AppWindowSize.expanded => 32,
      AppWindowSize.large => 40,
    };
  }
}
