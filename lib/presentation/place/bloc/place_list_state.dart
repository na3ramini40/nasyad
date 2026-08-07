part of 'place_list_bloc.dart';

sealed class PlaceListState extends Equatable {
  const PlaceListState();

  @override
  List<Object?> get props => [];
}

final class PlaceListInitial extends PlaceListState {
  const PlaceListInitial();
}

final class PlaceListLoading extends PlaceListState {
  const PlaceListLoading();
}

final class PlaceListLoaded extends PlaceListState {
  const PlaceListLoaded(this.places);

  final List<Place> places;

  @override
  List<Object?> get props => [places];
}

final class PlaceListError extends PlaceListState {
  const PlaceListError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
