import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:nasyad/presentation/app_lock/bloc/app_lock_cubit.dart';
import 'package:nasyad/presentation/app_lock/pages/unlock_page.dart';

/// Gates the main UI behind unlock when app lock is enabled and locked.
///
/// Splash, intro, and auth routes stay reachable (forgot-lock OTP).
///
/// [router] must be passed explicitly — [MaterialApp.router]'s `builder`
/// context is above [GoRouter]'s inherited widget.
class AppLockGate extends StatefulWidget {
  const AppLockGate({super.key, required this.router, required this.child});

  final GoRouter router;
  final Widget child;

  @override
  State<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends State<AppLockGate> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.router.routerDelegate.addListener(_onRouteChanged);
  }

  @override
  void didUpdateWidget(covariant AppLockGate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.router, widget.router)) {
      oldWidget.router.routerDelegate.removeListener(_onRouteChanged);
      widget.router.routerDelegate.addListener(_onRouteChanged);
    }
  }

  @override
  void dispose() {
    widget.router.routerDelegate.removeListener(_onRouteChanged);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _onRouteChanged() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final cubit = context.read<AppLockCubit>();
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        cubit.onAppPaused();
      case AppLifecycleState.resumed:
        cubit.onAppResumed();
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        break;
    }
  }

  bool _isExemptPath(String path) {
    return path == '/splash' || path == '/intro' || path.startsWith('/auth');
  }

  String _currentPath() {
    final matches = widget.router.routerDelegate.currentConfiguration;
    if (matches.isEmpty) {
      return widget.router.routeInformationProvider.value.uri.path;
    }
    return matches.uri.path;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppLockCubit, AppLockState>(
      builder: (context, lockState) {
        final path = _currentPath();
        final showUnlock =
            lockState.hydrated &&
            lockState.isEnabled &&
            lockState.isLocked &&
            !_isExemptPath(path);

        return Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (_) =>
              context.read<AppLockCubit>().onUserInteraction(),
          onPointerSignal: (_) =>
              context.read<AppLockCubit>().onUserInteraction(),
          child: Stack(
            fit: StackFit.expand,
            children: [
              IgnorePointer(
                ignoring: showUnlock,
                child: ExcludeSemantics(
                  excluding: showUnlock,
                  child: widget.child,
                ),
              ),
              if (showUnlock) const Positioned.fill(child: UnlockPage()),
            ],
          ),
        );
      },
    );
  }
}
