import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:nasyad/core/theme/app_breakpoints.dart';
import 'package:nasyad/core/theme/app_spacing.dart';

typedef ResponsiveWidgetBuilder = Widget Function(
  BuildContext context,
  AppWindowSize windowSize,
);

class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({super.key, required this.builder});

  final ResponsiveWidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        return builder(context, AppBreakpoints.ofWidth(width));
      },
    );
  }
}

class AppContent extends StatelessWidget {
  const AppContent({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
    this.align = Alignment.topCenter,
  });

  final Widget child;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;
  final Alignment align;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final windowSize = AppBreakpoints.ofWidth(width);
        final resolvedMax =
            maxWidth ?? AppBreakpoints.contentMaxWidth(windowSize);
        final targetWidth = resolvedMax.isInfinite
            ? width
            : math.min(resolvedMax, width);
        final resolvedPadding = padding ??
            EdgeInsets.symmetric(
              horizontal: AppBreakpoints.pagePadding(windowSize),
              vertical: AppSpacing.md,
            );

        return Align(
          alignment: align,
          child: SizedBox(
            width: targetWidth,
            height:
                constraints.hasBoundedHeight ? constraints.maxHeight : null,
            child: Padding(padding: resolvedPadding, child: child),
          ),
        );
      },
    );
  }
}

class ResponsiveDeviceGrid extends StatelessWidget {
  const ResponsiveDeviceGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.aspectRatio,
    this.spacing = AppSpacing.md,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final double? aspectRatio;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, windowSize) {
        final columns = AppBreakpoints.deviceGridColumns(windowSize);

        if (columns == 1) {
          return ListView.separated(
            itemCount: itemCount,
            separatorBuilder: (_, __) => SizedBox(height: spacing),
            itemBuilder: itemBuilder,
          );
        }

        return GridView.builder(
          itemCount: itemCount,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
            childAspectRatio: aspectRatio ?? 1.35,
          ),
          itemBuilder: itemBuilder,
        );
      },
    );
  }
}

class AppPageScaffold extends StatelessWidget {
  const AppPageScaffold({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.floatingActionButton,
    this.body,
    this.bottomNavigationBar,
    this.centerBody = true,
    this.useSafeArea = true,
  });

  final Widget? title;
  final Widget? leading;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? body;
  final Widget? bottomNavigationBar;
  final bool centerBody;
  final bool useSafeArea;

  @override
  Widget build(BuildContext context) {
    Widget? content = body;
    if (content != null && centerBody) {
      content = AppContent(child: content);
    }
    if (content != null && useSafeArea) {
      content = SafeArea(child: content);
    }

    return Scaffold(
      appBar: title == null && leading == null && actions == null
          ? null
          : AppBar(
              title: title,
              leading: leading,
              actions: actions,
            ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      body: content,
    );
  }
}
