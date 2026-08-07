part of 'profile_edit_bloc.dart';

sealed class ProfileEditEvent extends Equatable {
  const ProfileEditEvent();

  @override
  List<Object?> get props => [];
}

final class ProfileEditStarted extends ProfileEditEvent {
  const ProfileEditStarted();
}

final class ProfileEditNameChanged extends ProfileEditEvent {
  const ProfileEditNameChanged(this.name);

  final String name;

  @override
  List<Object?> get props => [name];
}

final class ProfileEditImagePicked extends ProfileEditEvent {
  const ProfileEditImagePicked(this.path);

  final String path;

  @override
  List<Object?> get props => [path];
}

final class ProfileEditSaveRequested extends ProfileEditEvent {
  const ProfileEditSaveRequested();
}
