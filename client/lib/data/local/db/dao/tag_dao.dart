import 'package:drift/drift.dart';
import 'package:nasyad/data/local/db/app_database.dart';
import 'package:nasyad/data/local/db/tables/device_tags_table.dart';
import 'package:nasyad/data/local/db/tables/tags_table.dart';

part 'tag_dao.g.dart';

@DriftAccessor(tables: [TagsTable, DeviceTagsTable])
class TagDao extends DatabaseAccessor<AppDatabase> with _$TagDaoMixin {
  TagDao(super.db);

  Stream<List<TagsTableData>> watchAll() {
    return (select(
      tagsTable,
    )..orderBy([(t) => OrderingTerm.asc(t.name)])).watch();
  }

  Future<List<TagsTableData>> getAll() {
    return (select(
      tagsTable,
    )..orderBy([(t) => OrderingTerm.asc(t.name)])).get();
  }

  Future<TagsTableData?> getById(String id) {
    return (select(tagsTable)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertTag(TagsTableCompanion tag) {
    return into(tagsTable).insert(tag);
  }

  Future<int> upsertTag(TagsTableCompanion tag) {
    return into(tagsTable).insertOnConflictUpdate(tag);
  }

  Future<bool> replaceTag(TagsTableData tag) {
    return update(tagsTable).replace(tag);
  }

  Future<void> deleteById(String id) async {
    await (delete(deviceTagsTable)..where((t) => t.tagId.equals(id))).go();
    await (delete(tagsTable)..where((t) => t.id.equals(id))).go();
  }

  Stream<List<TagsTableData>> watchTagsForDevice(String deviceId) {
    final query = select(tagsTable).join([
      innerJoin(deviceTagsTable, deviceTagsTable.tagId.equalsExp(tagsTable.id)),
    ])..where(deviceTagsTable.deviceId.equals(deviceId));
    query.orderBy([OrderingTerm.asc(tagsTable.name)]);
    return query.watch().map(
      (rows) => rows.map((row) => row.readTable(tagsTable)).toList(),
    );
  }

  Future<List<TagsTableData>> getTagsForDevice(String deviceId) async {
    final query = select(tagsTable).join([
      innerJoin(deviceTagsTable, deviceTagsTable.tagId.equalsExp(tagsTable.id)),
    ])..where(deviceTagsTable.deviceId.equals(deviceId));
    query.orderBy([OrderingTerm.asc(tagsTable.name)]);
    final rows = await query.get();
    return rows.map((row) => row.readTable(tagsTable)).toList();
  }

  Stream<List<DeviceTagsTableData>> watchAllLinks() {
    return select(deviceTagsTable).watch();
  }

  Future<List<DeviceTagsTableData>> getAllLinks() {
    return select(deviceTagsTable).get();
  }

  Future<void> setDeviceTags(String deviceId, List<String> tagIds) async {
    await transaction(() async {
      await (delete(
        deviceTagsTable,
      )..where((t) => t.deviceId.equals(deviceId))).go();
      for (final tagId in tagIds) {
        await into(deviceTagsTable).insert(
          DeviceTagsTableCompanion.insert(deviceId: deviceId, tagId: tagId),
        );
      }
    });
  }

  Future<void> upsertLink(DeviceTagsTableCompanion link) {
    return into(deviceTagsTable).insertOnConflictUpdate(link);
  }

  Future<void> deleteLinksForDevice(String deviceId) {
    return (delete(
      deviceTagsTable,
    )..where((t) => t.deviceId.equals(deviceId))).go();
  }
}
