import 'package:go_router/go_router.dart';
import 'package:nasyad/core/deep_link/deep_link_resolver.dart';

/// Stub entry point for platform link streams.
///
/// [install] is a no-op until a package such as `app_links` or go_router's
/// deep-link API is wired. [handleUri] is ready for manual or test invocation.
class DeepLinkHandler {
  DeepLinkHandler({required GoRouter router}) : _router = router;

  final GoRouter _router;

  /// Reserved for a future platform link subscription.
  void install() {}

  /// Reserved for cancelling a future platform link subscription.
  void dispose() {}

  /// Navigates when [uri] resolves to a known in-app location.
  void handleUri(Uri uri) {
    final location = DeepLinkResolver.resolveLocation(uri);
    if (location != null) {
      _router.go(location);
    }
  }
}
