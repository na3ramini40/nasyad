import 'package:equatable/equatable.dart';
import 'package:nasyad/domain/entities/geo_point.dart';
import 'package:nasyad/domain/entities/place_geometry_kind.dart';

class Place extends Equatable {
  const Place({
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

  bool get hasValidGeometry => points.length >= kind.minPoints;

  Place copyWith({
    String? id,
    String? name,
    PlaceGeometryKind? kind,
    List<GeoPoint>? points,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Place(
      id: id ?? this.id,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      points: points ?? this.points,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    kind,
    points,
    notes,
    createdAt,
    updatedAt,
  ];
}
