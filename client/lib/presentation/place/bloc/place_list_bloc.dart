import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nasyad/domain/entities/place.dart';
import 'package:nasyad/domain/usecases/place/delete_place_usecase.dart';
import 'package:nasyad/domain/usecases/place/watch_places_usecase.dart';

part 'place_list_event.dart';
part 'place_list_state.dart';

class PlaceListBloc extends Bloc<PlaceListEvent, PlaceListState> {
  PlaceListBloc({
    required WatchPlacesUsecase watchPlaces,
    required DeletePlaceUsecase deletePlace,
  }) : _watchPlaces = watchPlaces,
       _deletePlace = deletePlace,
       super(const PlaceListInitial()) {
    on<PlaceListStarted>(_onStarted);
    on<_PlaceListUpdated>(_onUpdated);
    on<_PlaceListWatchFailed>(_onWatchFailed);
    on<PlaceListDeleteRequested>(_onDelete);
  }

  final WatchPlacesUsecase _watchPlaces;
  final DeletePlaceUsecase _deletePlace;
  StreamSubscription<List<Place>>? _subscription;

  Future<void> _onStarted(
    PlaceListStarted event,
    Emitter<PlaceListState> emit,
  ) async {
    emit(const PlaceListLoading());
    await _subscription?.cancel();
    _subscription = _watchPlaces().listen(
      (items) => add(_PlaceListUpdated(items)),
      onError: (Object error, StackTrace _) =>
          add(_PlaceListWatchFailed(error)),
    );
  }

  void _onUpdated(_PlaceListUpdated event, Emitter<PlaceListState> emit) {
    emit(PlaceListLoaded(event.places));
  }

  void _onWatchFailed(
    _PlaceListWatchFailed event,
    Emitter<PlaceListState> emit,
  ) {
    emit(PlaceListError(event.error.toString()));
  }

  Future<void> _onDelete(
    PlaceListDeleteRequested event,
    Emitter<PlaceListState> emit,
  ) async {
    try {
      await _deletePlace(event.id);
    } catch (error) {
      emit(PlaceListError(error.toString()));
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
