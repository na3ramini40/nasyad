import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nasyad/core/location/location_reader.dart';
import 'package:nasyad/core/utils/id_generator.dart';
import 'package:nasyad/domain/entities/geo_point.dart';
import 'package:nasyad/domain/entities/place.dart';
import 'package:nasyad/domain/entities/place_geometry_kind.dart';
import 'package:nasyad/domain/usecases/place/create_place_usecase.dart';
import 'package:nasyad/domain/usecases/place/delete_place_usecase.dart';
import 'package:nasyad/domain/usecases/place/get_place_usecase.dart';
import 'package:nasyad/domain/usecases/place/update_place_usecase.dart';

part 'place_edit_event.dart';
part 'place_edit_state.dart';

class PlaceEditBloc extends Bloc<PlaceEditEvent, PlaceEditState> {
  PlaceEditBloc({
    this.placeId,
    PlaceGeometryKind? initialKind,
    required GetPlaceUsecase getPlace,
    required CreatePlaceUsecase createPlace,
    required UpdatePlaceUsecase updatePlace,
    required DeletePlaceUsecase deletePlace,
    LocationReader? locationReader,
  }) : _getPlace = getPlace,
       _createPlace = createPlace,
       _updatePlace = updatePlace,
       _deletePlace = deletePlace,
       _locationReader = locationReader ?? const LocationReader(),
       super(
         PlaceEditState(
           isEdit: placeId != null,
           kind: initialKind ?? PlaceGeometryKind.point,
         ),
       ) {
    on<PlaceEditStarted>(_onStarted);
    on<PlaceEditNameChanged>(_onNameChanged);
    on<PlaceEditKindChanged>(_onKindChanged);
    on<PlaceEditMapTapped>(_onMapTapped);
    on<PlaceEditUndoPointRequested>(_onUndoPoint);
    on<PlaceEditUseCurrentLocationRequested>(_onUseCurrentLocation);
    on<PlaceEditSaveRequested>(_onSave);
    on<PlaceEditDeleteRequested>(_onDelete);
  }

  final String? placeId;
  final GetPlaceUsecase _getPlace;
  final CreatePlaceUsecase _createPlace;
  final UpdatePlaceUsecase _updatePlace;
  final DeletePlaceUsecase _deletePlace;
  final LocationReader _locationReader;
  Place? _existing;

  Future<void> _onStarted(
    PlaceEditStarted event,
    Emitter<PlaceEditState> emit,
  ) async {
    if (placeId == null) {
      emit(
        state.copyWith(
          status: PlaceEditStatus.ready,
          kind: event.initialKind ?? state.kind,
          clearError: true,
        ),
      );
      return;
    }

    emit(state.copyWith(status: PlaceEditStatus.loading, clearError: true));
    try {
      final place = await _getPlace(placeId!);
      _existing = place;
      if (place == null) {
        emit(
          state.copyWith(
            status: PlaceEditStatus.failure,
            errorMessage: 'Place not found',
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          status: PlaceEditStatus.ready,
          name: place.name,
          kind: place.kind,
          points: place.points,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: PlaceEditStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void _onNameChanged(
    PlaceEditNameChanged event,
    Emitter<PlaceEditState> emit,
  ) {
    emit(state.copyWith(name: event.name, clearError: true));
  }

  void _onKindChanged(
    PlaceEditKindChanged event,
    Emitter<PlaceEditState> emit,
  ) {
    if (event.kind == state.kind) return;
    emit(state.copyWith(kind: event.kind, points: const [], clearError: true));
  }

  void _onMapTapped(PlaceEditMapTapped event, Emitter<PlaceEditState> emit) {
    final points = switch (state.kind) {
      PlaceGeometryKind.point => [event.point],
      PlaceGeometryKind.line ||
      PlaceGeometryKind.polygon => [...state.points, event.point],
    };
    emit(state.copyWith(points: points, clearError: true));
  }

  void _onUndoPoint(
    PlaceEditUndoPointRequested event,
    Emitter<PlaceEditState> emit,
  ) {
    if (state.points.isEmpty) return;
    emit(
      state.copyWith(
        points: state.points.sublist(0, state.points.length - 1),
        clearError: true,
      ),
    );
  }

  Future<void> _onUseCurrentLocation(
    PlaceEditUseCurrentLocationRequested event,
    Emitter<PlaceEditState> emit,
  ) async {
    emit(state.copyWith(clearLocationDenied: true, clearError: true));
    try {
      final point = await _locationReader.getCurrentPosition();
      if (point == null) {
        emit(state.copyWith(locationDenied: true));
        return;
      }
      add(PlaceEditMapTapped(point));
    } catch (error) {
      emit(
        state.copyWith(
          status: PlaceEditStatus.ready,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onSave(
    PlaceEditSaveRequested event,
    Emitter<PlaceEditState> emit,
  ) async {
    if (state.name.trim().isEmpty) {
      emit(
        state.copyWith(
          status: PlaceEditStatus.ready,
          errorMessage: event.nameRequiredMessage,
        ),
      );
      return;
    }
    if (state.points.length < state.kind.minPoints) {
      emit(
        state.copyWith(
          status: PlaceEditStatus.ready,
          errorMessage: event.geometryRequiredMessage,
        ),
      );
      return;
    }

    emit(state.copyWith(status: PlaceEditStatus.saving, clearError: true));
    final now = DateTime.now();
    try {
      if (_existing == null) {
        await _createPlace(
          Place(
            id: IdGenerator.newId(),
            name: state.name.trim(),
            kind: state.kind,
            points: state.points,
            createdAt: now,
            updatedAt: now,
          ),
        );
      } else {
        await _updatePlace(
          _existing!.copyWith(
            name: state.name.trim(),
            kind: state.kind,
            points: state.points,
            updatedAt: now,
          ),
        );
      }
      emit(state.copyWith(status: PlaceEditStatus.saved));
    } catch (error) {
      emit(
        state.copyWith(
          status: PlaceEditStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onDelete(
    PlaceEditDeleteRequested event,
    Emitter<PlaceEditState> emit,
  ) async {
    if (placeId == null) return;
    emit(state.copyWith(status: PlaceEditStatus.saving, clearError: true));
    try {
      await _deletePlace(placeId!);
      emit(state.copyWith(status: PlaceEditStatus.deleted));
    } catch (error) {
      emit(
        state.copyWith(
          status: PlaceEditStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
