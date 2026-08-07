/// OpenStreetMap tile settings for [flutter_map].
///
/// See https://operations.osmfoundation.org/policies/tiles/
abstract final class OsmMapConfig {
  static const tileUrlTemplate =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  /// Must identify the app when fetching OSM tiles.
  static const userAgentPackageName = 'amini.apps.nasyad';

  static const attributionLabel = '© OpenStreetMap contributors';
}
