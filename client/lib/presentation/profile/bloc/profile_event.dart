part of 'profile_bloc.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

final class ProfileStarted extends ProfileEvent {
  const ProfileStarted();
}

final class ProfileRefreshRequested extends ProfileEvent {
  const ProfileRefreshRequested();
}

final class ProfileSignOutRequested extends ProfileEvent {
  const ProfileSignOutRequested();
}

final class ProfileSessionUpdated extends ProfileEvent {
  const ProfileSessionUpdated(this.session);

  final AuthSession session;

  @override
  List<Object?> get props => [session];
}
