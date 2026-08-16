import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nasyad/core/theme/ui_scale.dart';
import 'package:nasyad/core/theme/ui_scale_cubit.dart';

/// Scales the whole subtree (fonts + layout) and handles two-finger pinch.
///
/// Nested map gesture arenas may still win for pinch-zoom on place maps.
class UiScaleWrapper extends StatefulWidget {
  const UiScaleWrapper({super.key, required this.child});

  final Widget child;

  @override
  State<UiScaleWrapper> createState() => _UiScaleWrapperState();
}

class _UiScaleWrapperState extends State<UiScaleWrapper> {
  double? _pinchBase;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UiScaleCubit, double>(
      builder: (context, scale) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onScaleStart: (details) {
            if (details.pointerCount >= 2) {
              _pinchBase = scale;
            }
          },
          onScaleUpdate: (details) {
            if (details.pointerCount < 2 || _pinchBase == null) return;
            context.read<UiScaleCubit>().setScale(_pinchBase! * details.scale);
          },
          onScaleEnd: (_) => _pinchBase = null,
          child: _ScaledBox(scale: scale, child: widget.child),
        );
      },
    );
  }
}

class _ScaledBox extends StatelessWidget {
  const _ScaledBox({required this.scale, required this.child});

  final double scale;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final clamped = UiScale.clamp(scale);
    if ((clamped - 1.0).abs() < 0.001) {
      return child;
    }

    final size = mediaQuery.size;
    final width = size.width / clamped;
    final height = size.height / clamped;

    return ClipRect(
      child: MediaQuery(
        data: mediaQuery.copyWith(size: Size(width, height)),
        child: Transform.scale(
          scale: clamped,
          alignment: Alignment.topLeft,
          child: SizedBox(width: width, height: height, child: child),
        ),
      ),
    );
  }
}
