import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:nasyad/core/deep_link/deep_link_resolver.dart';

/// Subscribes to platform `nasyad://` links and navigates via [GoRouter.go].
class DeepLinkHandler {
  DeepLinkHandler({required GoRouter router, AppLinks? appLinks})
    : _router = router,
      _appLinks = appLinks ?? AppLinks();

  final GoRouter _router;
  final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  /// Listens for cold- and warm-start platform links.
  void install() {
    _linkSubscription ??= _appLinks.uriLinkStream.listen(_onIncomingUri);
  }

  void dispose() {
    unawaited(_linkSubscription?.cancel());
    _linkSubscription = null;
  }

  void _onIncomingUri(Uri uri) {
    WidgetsBinding.instance.addPostFrameCallback((_) => handleUri(uri));
  }

  /// Navigates when [uri] resolves to a known in-app location.
  void handleUri(Uri uri) {
    final location = DeepLinkResolver.resolveLocation(uri);
    if (location != null) {
      _router.go(location);
    }
  }
}
