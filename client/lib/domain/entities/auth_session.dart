import 'package:equatable/equatable.dart';
import 'package:nasyad/domain/entities/user_profile.dart';

class AuthSession extends Equatable {
  const AuthSession({this.token, this.profile});

  static const guest = AuthSession();

  final String? token;
  final UserProfile? profile;

  bool get isSignedIn => token != null && token!.isNotEmpty && profile != null;

  AuthSession copyWith({
    String? token,
    UserProfile? profile,
    bool clearToken = false,
    bool clearProfile = false,
  }) {
    return AuthSession(
      token: clearToken ? null : (token ?? this.token),
      profile: clearProfile ? null : (profile ?? this.profile),
    );
  }

  @override
  List<Object?> get props => [token, profile];
}
