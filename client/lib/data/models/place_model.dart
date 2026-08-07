import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:nasyad/data/local/db/app_database.dart';
import 'package:nasyad/domain/entities/geo_point.dart';
import 'package:nasyad/domain/entities/place.dart';
import 'package:nasyad/domain/entities/place_geometry_kind.dart';

class PlaceModel {
  const PlaceModel({
    required this.id,
    required this.name,
    required this.kind,
    required this.points,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final PlaceGeometryKind kind;
  final List<GeoPoint> points;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Place toEntity() {
    return Place(
      id: id,
      name: name,
      kind: kind,
      points: points,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory PlaceModel.fromEntity(Place place) {
    return PlaceModel(
      id: place.id,
      name: place.name,
      kind: place.kind,
      points: place.points,
      notes: place.notes,
      createdAt: place.createdAt,
      updatedAt: place.updatedAt,
    );
  }

  factory PlaceModel.fromRow(PlacesTableData row) {
    return PlaceModel(
      id: row.id,
      name: row.name,
      kind: PlaceGeometryKind.fromStorage(row.kind),
      points: decodePoints(row.pointsJson),
      notes: row.notes,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  PlacesTableCompanion toInsertCompanion() {
    return PlacesTableCompanion.insert(
      id: id,
      name: name,
      kind: kind.storageValue,
      pointsJson: encodePoints(points),
      notes: Value(notes),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  PlacesTableData toRow() {
    return PlacesTableData(
      id: id,
      name: name,
      kind: kind.storageValue,
      pointsJson: encodePoints(points),
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static String encodePoints(List<GeoPoint> points) {
    return jsonEncode(
      points
          .map((point) => {'lat': point.latitude, 'lng': point.longitude})
          .toList(growable: false),
    );
  }

  static List<GeoPoint> decodePoints(String json) {
    final decoded = jsonDecode(json);
    if (decoded is! List) return const [];

    return decoded
        .whereType<Map>()
        .map(
          (entry) => GeoPoint(
            latitude: (entry['lat'] as num).toDouble(),
            longitude: (entry['lng'] as num).toDouble(),
          ),
        )
        .toList(growable: false);
  }
}
