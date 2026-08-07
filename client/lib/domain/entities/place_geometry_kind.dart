enum PlaceGeometryKind {
  point,
  line,
  polygon;

  String get storageValue => name;

  int get minPoints => switch (this) {
    PlaceGeometryKind.point => 1,
    PlaceGeometryKind.line => 2,
    PlaceGeometryKind.polygon => 3,
  };

  static PlaceGeometryKind fromStorage(String value) {
    return PlaceGeometryKind.values.firstWhere(
      (kind) => kind.storageValue == value,
      orElse: () => PlaceGeometryKind.point,
    );
  }
}
