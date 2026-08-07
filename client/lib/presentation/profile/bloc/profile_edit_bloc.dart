import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nasyad/domain/usecases/auth/update_profile_usecase.dart';
import 'package:nasyad/domain/usecases/auth/watch_auth_session_usecase.dart';

part 'profile_edit_event.dart';
part 'profile_edit_state.dart';

class ProfileEditBloc extends Bloc<ProfileEditEvent, ProfileEditState> {
  ProfileEditBloc({
    required WatchAuthSessionUsecase watchAuthSession,
    required UpdateProfileUsecase updateProfile,
  }) : _watchAuthSession = watchAuthSession,
       _updateProfile = updateProfile,
       super(const ProfileEditState()) {
    on<ProfileEditStarted>(_onStarted);
    on<ProfileEditNameChanged>(_onNameChanged);
    on<ProfileEditImagePicked>(_onImagePicked);
    on<ProfileEditSaveRequested>(_onSave);
  }

  final WatchAuthSessionUsecase _watchAuthSession;
  final UpdateProfileUsecase _updateProfile;

  Future<void> _onStarted(
    ProfileEditStarted event,
    Emitter<ProfileEditState> emit,
  ) async {
    emit(state.copyWith(status: ProfileEditStatus.loading, clearError: true));
    final session = await _watchAuthSession().first;
    final profile = session.profile;
    if (profile == null) {
      emit(
        state.copyWith(
          status: ProfileEditStatus.failure,
          errorMessage: 'not_signed_in',
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        status: ProfileEditStatus.ready,
        userId: profile.id,
        phone: profile.phone,
        name: profile.name ?? '',
        imageUrl: profile.imageUrl,
        clearError: true,
      ),
    );
  }

  void _onNameChanged(
    ProfileEditNameChanged event,
    Emitter<ProfileEditState> emit,
  ) {
    emit(state.copyWith(name: event.name, clearError: true));
  }

  void _onImagePicked(
    ProfileEditImagePicked event,
    Emitter<ProfileEditState> emit,
  ) {
    emit(state.copyWith(localImagePath: event.path, clearError: true));
  }

  Future<void> _onSave(
    ProfileEditSaveRequested event,
    Emitter<ProfileEditState> emit,
  ) async {
    emit(state.copyWith(status: ProfileEditStatus.saving, clearError: true));
    try {
      final updated = await _updateProfile(
        name: state.name.trim().isEmpty ? '' : state.name.trim(),
        imageFile: state.localImagePath == null
            ? null
            : File(state.localImagePath!),
      );
      emit(
        state.copyWith(
          status: ProfileEditStatus.success,
          userId: updated.id,
          phone: updated.phone,
          name: updated.name ?? '',
          imageUrl: updated.imageUrl,
          clearLocalImage: true,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: ProfileEditStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
