import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nasyad/domain/entities/auth_session.dart';
import 'package:nasyad/domain/usecases/auth/get_profile_usecase.dart';
import 'package:nasyad/domain/usecases/auth/sign_out_usecase.dart';
import 'package:nasyad/domain/usecases/auth/watch_auth_session_usecase.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({
    required WatchAuthSessionUsecase watchAuthSession,
    required GetProfileUsecase getProfile,
    required SignOutUsecase signOut,
  }) : _watchAuthSession = watchAuthSession,
       _getProfile = getProfile,
       _signOut = signOut,
       super(const ProfileState()) {
    on<ProfileStarted>(_onStarted);
    on<ProfileRefreshRequested>(_onRefresh);
    on<ProfileSignOutRequested>(_onSignOut);
    on<ProfileSessionUpdated>(_onSessionUpdated);
  }

  final WatchAuthSessionUsecase _watchAuthSession;
  final GetProfileUsecase _getProfile;
  final SignOutUsecase _signOut;
  StreamSubscription<AuthSession>? _subscription;

  Future<void> _onStarted(
    ProfileStarted event,
    Emitter<ProfileState> emit,
  ) async {
    await _subscription?.cancel();
    _subscription = _watchAuthSession().listen((session) {
      add(ProfileSessionUpdated(session));
    });
  }

  void _onSessionUpdated(
    ProfileSessionUpdated event,
    Emitter<ProfileState> emit,
  ) {
    emit(
      state.copyWith(
        status: ProfileStatus.ready,
        session: event.session,
        clearError: true,
      ),
    );
  }

  Future<void> _onRefresh(
    ProfileRefreshRequested event,
    Emitter<ProfileState> emit,
  ) async {
    if (!state.session.isSignedIn) return;
    emit(state.copyWith(status: ProfileStatus.loading, clearError: true));
    try {
      final profile = await _getProfile();
      emit(
        state.copyWith(
          status: ProfileStatus.ready,
          session: state.session.copyWith(profile: profile),
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onSignOut(
    ProfileSignOutRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.signingOut, clearError: true));
    try {
      await _signOut();
      emit(
        state.copyWith(
          status: ProfileStatus.ready,
          session: AuthSession.guest,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
