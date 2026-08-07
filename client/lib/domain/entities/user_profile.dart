import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  const UserProfile({
    required this.id,
    required this.phone,
    this.name,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String phone;
  final String? name;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile copyWith({
    String? id,
    String? phone,
    String? name,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearName = false,
    bool clearImageUrl = false,
  }) {
    return UserProfile(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      name: clearName ? null : (name ?? this.name),
      imageUrl: clearImageUrl ? null : (imageUrl ?? this.imageUrl),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, phone, name, imageUrl, createdAt, updatedAt];
}
