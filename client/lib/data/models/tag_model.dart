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
}
