import 'dart:convert';

import 'package:nasyad/domain/entities/user_profile.dart';

class UserProfileModel {
  const UserProfileModel({
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

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      phone: json['phone'] as String,
      name: json['name'] as String?,
      imageUrl: json['image_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'phone': phone,
    'name': name,
    'image_url': imageUrl,
    'created_at': createdAt.toUtc().toIso8601String(),
    'updated_at': updatedAt.toUtc().toIso8601String(),
  };

  UserProfile toEntity() => UserProfile(
    id: id,
    phone: phone,
    name: name,
    imageUrl: imageUrl,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  factory UserProfileModel.fromEntity(UserProfile profile) {
    return UserProfileModel(
      id: profile.id,
      phone: profile.phone,
      name: profile.name,
      imageUrl: profile.imageUrl,
      createdAt: profile.createdAt,
      updatedAt: profile.updatedAt,
    );
  }

  String encode() => jsonEncode(toJson());

  static UserProfileModel? tryDecode(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return UserProfileModel.fromJson(map);
    } catch (_) {
      return null;
    }
  }
}
