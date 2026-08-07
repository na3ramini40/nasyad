import 'package:equatable/equatable.dart';

/// Evaluated remote feature flags plus freshness metadata.
class AppConfigSnapshot extends Equatable {
  const AppConfigSnapshot({
    required this.features,
    this.updatedAt,
    this.fetchedAt,
  });

  static const empty = AppConfigSnapshot(features: {});

  final Map<String, bool> features;
  final DateTime? updatedAt;
  final DateTime? fetchedAt;

  /// Unknown / missing keys are safe-default `false`.
  bool isEnabled(String key) => features[key] ?? false;

  AppConfigSnapshot copyWith({
    Map<String, bool>? features,
    DateTime? updatedAt,
    DateTime? fetchedAt,
  }) {
    return AppConfigSnapshot(
      features: features ?? this.features,
      updatedAt: updatedAt ?? this.updatedAt,
      fetchedAt: fetchedAt ?? this.fetchedAt,
    );
  }

  @override
  List<Object?> get props => [features, updatedAt, fetchedAt];
}
