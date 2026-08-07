import 'package:nasyad/core/deep_link/deep_link_mapper.dart';
import 'package:nasyad/core/deep_link/deep_link_parser.dart';
import 'package:nasyad/core/deep_link/deep_link_target.dart';

/// Resolves external URIs into in-app router locations.
abstract final class DeepLinkResolver {
  static DeepLinkTarget? parseTarget(Uri uri) => DeepLinkParser.parse(uri);

  static String? resolveLocation(Uri uri) {
    final target = parseTarget(uri);
    if (target == null) {
      return null;
    }
    return DeepLinkMapper.toLocation(target);
  }

  static String? resolveLocationFromString(String link) {
    final uri = Uri.tryParse(link);
    if (uri == null) {
      return null;
    }
    return resolveLocation(uri);
  }
}
