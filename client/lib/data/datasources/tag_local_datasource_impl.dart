import 'package:nasyad/data/datasources/tag_local_datasource.dart';
import 'package:nasyad/data/local/db/dao/tag_dao.dart';
import 'package:nasyad/data/models/device_tag_link_model.dart';
import 'package:nasyad/data/models/tag_model.dart';

class TagLocalDataSourceImpl implements TagLocalDataSource {
  TagLocalDataSourceImpl(this._dao);

  final TagDao _dao;

  @override
  Stream<List<TagModel>> watchTags() {
    return _dao.watchAll().map(
      (rows) => rows.map(TagModel.fromRow).toList(growable: false),
    );
  }

  @override
  Future<List<TagModel>> getAllTags() async {
    final rows = await _dao.getAll();
    return rows.map(TagModel.fromRow).toList(growable: false);
  }

  @override
  Future<TagModel?> getTag(String id) async {
    final row = await _dao.getById(id);
    return row == null ? null : TagModel.fromRow(row);
  }

  @override
  Future<void> insertTag(TagModel tag) {
    return _dao.insertTag(tag.toInsertCompanion());
  }

  @override
  Future<void> updateTag(TagModel tag) {
    return _dao.replaceTag(tag.toRow());
  }

  @override
  Future<void> upsertTag(TagModel tag) {
    return _dao.upsertTag(tag.toInsertCompanion());
  }

  @override
  Future<void> deleteTag(String id) {
    return _dao.deleteById(id);
  }

  @override
  Stream<List<TagModel>> watchTagsForDevice(String deviceId) {
    return _dao
        .watchTagsForDevice(deviceId)
        .map((rows) => rows.map(TagModel.fromRow).toList(growable: false));
  }

  @override
  Future<List<TagModel>> getTagsForDevice(String deviceId) async {
    final rows = await _dao.getTagsForDevice(deviceId);
    return rows.map(TagModel.fromRow).toList(growable: false);
  }

  @override
  Future<void> setDeviceTags(String deviceId, List<String> tagIds) {
    return _dao.setDeviceTags(deviceId, tagIds);
  }

  @override
  Stream<List<DeviceTagLinkModel>> watchDeviceTagLinks() {
    return _dao.watchAllLinks().map(
      (rows) => rows.map(DeviceTagLinkModel.fromRow).toList(growable: false),
    );
  }

  @override
  Future<List<DeviceTagLinkModel>> getDeviceTagLinks() async {
    final rows = await _dao.getAllLinks();
    return rows.map(DeviceTagLinkModel.fromRow).toList(growable: false);
  }

  @override
  Future<DeviceTagLinkModel?> getDeviceTagLink(
    String deviceId,
    String tagId,
  ) async {
    final row = await _dao.getLink(deviceId, tagId);
    return row == null ? null : DeviceTagLinkModel.fromRow(row);
  }

  @override
  Future<void> upsertDeviceTagLink(DeviceTagLinkModel link) {
    return _dao.upsertLink(link.toInsertCompanion());
  }

  @override
  Future<void> deleteLinksForDevice(String deviceId) {
    return _dao.deleteLinksForDevice(deviceId);
  }
}
