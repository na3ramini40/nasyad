part of 'profile_edit_bloc.dart';

enum ProfileEditStatus { loading, ready, saving, success, failure }

final class ProfileEditState extends Equatable {
  const ProfileEditState({
    this.status = ProfileEditStatus.loading,
    this.userId = '',
    this.phone = '',
    this.name = '',
    this.imageUrl,
    this.localImagePath,
    this.errorMessage,
  });

  final ProfileEditStatus status;
  final String userId;
  final String phone;
  final String name;
  final String? imageUrl;
  final String? localImagePath;
  final String? errorMessage;

  ProfileEditState copyWith({
    ProfileEditStatus? status,
    String? userId,
    String? phone,
    String? name,
    String? imageUrl,
    String? localImagePath,
    String? errorMessage,
    bool clearError = false,
    bool clearLocalImage = false,
  }) {
    return ProfileEditState(
      status: status ?? this.status,
      userId: userId ?? this.userId,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      localImagePath: clearLocalImage
          ? null
          : (localImagePath ?? this.localImagePath),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    status,
    userId,
    phone,
    name,
    imageUrl,
    localImagePath,
    errorMessage,
  ];
}
