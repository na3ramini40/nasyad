part of 'profile_bloc.dart';

enum ProfileStatus { loading, ready, signingOut, failure }

final class ProfileState extends Equatable {
  const ProfileState({
    this.status = ProfileStatus.loading,
    this.session = AuthSession.guest,
    this.errorMessage,
  });

  final ProfileStatus status;
  final AuthSession session;
  final String? errorMessage;

  bool get isGuest => !session.isSignedIn;

  ProfileState copyWith({
    ProfileStatus? status,
    AuthSession? session,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ProfileState(
      status: status ?? this.status,
      session: session ?? this.session,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, session, errorMessage];
}
