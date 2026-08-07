part of 'place_list_bloc.dart';

sealed class PlaceListEvent extends Equatable {
  const PlaceListEvent();

  @override
  List<Object?> get props => [];
}

final class PlaceListStarted extends PlaceListEvent {
  const PlaceListStarted();
}

final class PlaceListDeleteRequested extends PlaceListEvent {
  const PlaceListDeleteRequested(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

final class _PlaceListUpdated extends PlaceListEvent {
  const _PlaceListUpdated(this.places);

  final List<Place> places;

  @override
  List<Object?> get props => [places];
}

final class _PlaceListWatchFailed extends PlaceListEvent {
  const _PlaceListWatchFailed(this.error);

  final Object error;

  @override
  List<Object?> get props => [error];
}
