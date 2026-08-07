part of 'place_edit_bloc.dart';

enum PlaceEditStatus { loading, ready, saving, saved, deleted, failure }

sealed class PlaceEditEvent extends Equatable {
  const PlaceEditEvent();

  @override
  List<Object?> get props => [];
}

final class PlaceEditStarted extends PlaceEditEvent {
  const PlaceEditStarted({this.initialKind});
  final PlaceGeometryKind? initialKind;

  @override
  List<Object?> get props => [initialKind];
}

final class PlaceEditNameChanged extends PlaceEditEvent {
  const PlaceEditNameChanged(this.name);

  final String name;

  @override
  List<Object?> get props => [name];
}

final class PlaceEditKindChanged extends PlaceEditEvent {
  const PlaceEditKindChanged(this.kind);

  final PlaceGeometryKind kind;

  @override
  List<Object?> get props => [kind];
}

final class PlaceEditMapTapped extends PlaceEditEvent {
  const PlaceEditMapTapped(this.point);

  final GeoPoint point;

  @override
  List<Object?> get props => [point];
}

final class PlaceEditUndoPointRequested extends PlaceEditEvent {
  const PlaceEditUndoPointRequested();
}

final class PlaceEditUseCurrentLocationRequested extends PlaceEditEvent {
  const PlaceEditUseCurrentLocationRequested();
}

final class PlaceEditSaveRequested extends PlaceEditEvent {
  const PlaceEditSaveRequested({
    required this.nameRequiredMessage,
    required this.geometryRequiredMessage,
  });

  final String nameRequiredMessage;
  final String geometryRequiredMessage;

  @override
  List<Object?> get props => [nameRequiredMessage, geometryRequiredMessage];
}

final class PlaceEditDeleteRequested extends PlaceEditEvent {
  const PlaceEditDeleteRequested();
}
