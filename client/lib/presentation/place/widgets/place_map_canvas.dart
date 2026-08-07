import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:nasyad/core/location/location_reader.dart';
import 'package:nasyad/core/map/osm_map_config.dart';
import 'package:nasyad/core/theme/app_radius.dart';
import 'package:nasyad/core/theme/app_spacing.dart';
import 'package:nasyad/domain/entities/geo_point.dart';
import 'package:nasyad/domain/entities/place_geometry_kind.dart';

class PlaceMapCanvas extends StatefulWidget {
  const PlaceMapCanvas({
    super.key,
    required this.kind,
    required this.points,
    required this.onTap,
    required this.hint,
  });

  final PlaceGeometryKind kind;
  final List<GeoPoint> points;
  final ValueChanged<GeoPoint> onTap;
  final String hint;

  @override
  State<PlaceMapCanvas> createState() => _PlaceMapCanvasState();
}

class _PlaceMapCanvasState extends State<PlaceMapCanvas> {
  final MapController _controller = MapController();

  @override
  void didUpdateWidget(covariant PlaceMapCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.points.isNotEmpty &&
        (oldWidget.points.isEmpty ||
            oldWidget.points.last != widget.points.last)) {
      _moveTo(widget.points.last);
    }
  }

  void _moveTo(GeoPoint point) {
    _controller.move(
      LatLng(point.latitude, point.longitude),
      _controller.camera.zoom,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final center = widget.points.isNotEmpty
        ? LatLng(widget.points.first.latitude, widget.points.first.longitude)
        : LatLng(defaultMapCenter.latitude, defaultMapCenter.longitude);
    final latLngPoints = widget.points
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList(growable: false);

    return ClipRRect(
      borderRadius: AppRadius.borderLg,
      child: Stack(
        children: [
          FlutterMap(
            mapController: _controller,
            options: MapOptions(
              initialCenter: center,
              initialZoom: widget.points.isEmpty ? 12 : 14,
              onTap: (_, point) {
                widget.onTap(
                  GeoPoint(
                    latitude: point.latitude,
                    longitude: point.longitude,
                  ),
                );
              },
            ),
            children: [
              TileLayer(
                urlTemplate: OsmMapConfig.tileUrlTemplate,
                userAgentPackageName: OsmMapConfig.userAgentPackageName,
              ),
              if (widget.kind == PlaceGeometryKind.line &&
                  latLngPoints.length >= 2)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: latLngPoints,
                      color: scheme.secondary,
                      strokeWidth: 4,
                    ),
                  ],
                ),
              if (widget.kind == PlaceGeometryKind.polygon &&
                  latLngPoints.length >= 3)
                PolygonLayer(
                  polygons: [
                    Polygon(
                      points: latLngPoints,
                      color: scheme.secondary.withValues(alpha: 0.2),
                      borderColor: scheme.secondary,
                      borderStrokeWidth: 3,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  for (var i = 0; i < latLngPoints.length; i++)
                    Marker(
                      point: latLngPoints[i],
                      width: 36,
                      height: 36,
                      child: _MapMarker(
                        index: i + 1,
                        isSingle: widget.kind == PlaceGeometryKind.point,
                      ),
                    ),
                ],
              ),
            ],
          ),
          Positioned(
            top: AppSpacing.sm,
            left: AppSpacing.sm,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: scheme.surface.withValues(alpha: 0.88),
                borderRadius: AppRadius.borderSm,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                child: Text(
                  OsmMapConfig.attributionLabel,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: AppSpacing.md,
            right: AppSpacing.md,
            bottom: AppSpacing.md,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: scheme.surface.withValues(alpha: 0.92),
                borderRadius: AppRadius.borderMd,
                boxShadow: [
                  BoxShadow(
                    color: scheme.shadow.withValues(alpha: 0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Text(
                  widget.hint,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapMarker extends StatelessWidget {
  const _MapMarker({required this.index, required this.isSingle});

  final int index;
  final bool isSingle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (isSingle) {
      return Icon(Icons.place, color: scheme.secondary, size: 36);
    }

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: scheme.secondary,
        shape: BoxShape.circle,
        border: Border.all(color: scheme.surface, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        '$index',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: scheme.onSecondary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
