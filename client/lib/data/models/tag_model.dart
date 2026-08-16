import 'package:nasyad/data/local/db/app_database.dart';
import 'package:nasyad/domain/entities/tag.dart';

class TagModel {
  const TagModel({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  Tag toEntity() {
    return Tag(id: id, name: name, createdAt: createdAt, updatedAt: updatedAt);
  }

  factory TagModel.fromEntity(Tag tag) {
    return TagModel(
      id: tag.id,
      name: tag.name,
      createdAt: tag.createdAt,
      updatedAt: tag.updatedAt,
    );
  }

  factory TagModel.fromRow(TagsTableData row) {
    return TagModel(
      id: row.id,
      name: row.name,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  TagsTableCompanion toInsertCompanion() {
    return TagsTableCompanion.insert(
      id: id,
      name: name,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  TagsTableData toRow() {
    return TagsTableData(
      id: id,
      name: name,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Snake_case wire shape matching server [TagSerializer].
  Map<String, dynamic> toSyncJson() => {
    'id': id,
    'name': name,
    'created_at': createdAt.toUtc().toIso8601String(),
    'updated_at': updatedAt.toUtc().toIso8601String(),
  };

  factory TagModel.fromSyncJson(Map<String, dynamic> json) {
    return TagModel(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: _parseTagIso(json['created_at']) ?? DateTime.now().toUtc(),
      updatedAt: _parseTagIso(json['updated_at']) ?? DateTime.now().toUtc(),
    );
  }
}

DateTime? _parseTagIso(Object? value) {
  if (value is! String || value.isEmpty) return null;
  return DateTime.tryParse(value)?.toUtc();
}
