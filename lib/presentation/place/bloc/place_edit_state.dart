part of 'place_edit_bloc.dart';

class PlaceEditState extends Equatable {
  const PlaceEditState({
    required this.isEdit,
    this.status = PlaceEditStatus.loading,
    this.name = '',
    this.kind = PlaceGeometryKind.point,
    this.points = const [],
    this.errorMessage,
    this.locationDenied = false,
  });

  final bool isEdit;
  final PlaceEditStatus status;
  final String name;
  final PlaceGeometryKind kind;
  final List<GeoPoint> points;
  final String? errorMessage;
  final bool locationDenied;

  bool get canUndoPoint => points.isNotEmpty;

  bool get canSave => name.trim().isNotEmpty && points.length >= kind.minPoints;

  PlaceEditState copyWith({
    bool? isEdit,
    PlaceEditStatus? status,
    String? name,
    PlaceGeometryKind? kind,
    List<GeoPoint>? points,
    String? errorMessage,
    bool? locationDenied,
    bool clearError = false,
    bool clearLocationDenied = false,
  }) {
    return PlaceEditState(
      isEdit: isEdit ?? this.isEdit,
      status: status ?? this.status,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      points: points ?? this.points,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      locationDenied: clearLocationDenied
          ? false
          : locationDenied ?? this.locationDenied,
    );
  }

  @override
  List<Object?> get props => [
    isEdit,
    status,
    name,
    kind,
    points,
    errorMessage,
    locationDenied,
  ];
}
