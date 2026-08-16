import 'package:nasyad/data/datasources/tag_local_datasource.dart';
import 'package:nasyad/data/models/tag_model.dart';
import 'package:nasyad/domain/entities/device_tag_link.dart';
import 'package:nasyad/domain/entities/tag.dart';
import 'package:nasyad/domain/repositories/tag_repository.dart';

class TagRepositoryImpl implements TagRepository {
  TagRepositoryImpl(this._source);

  final TagLocalDataSource _source;

  @override
  Stream<List<Tag>> watchTags() {
    return _source.watchTags().map(
      (models) => models.map((m) => m.toEntity()).toList(growable: false),
    );
  }

  @override
  Future<List<Tag>> getAllTags() async {
    final models = await _source.getAllTags();
    return models.map((m) => m.toEntity()).toList(growable: false);
  }

  @override
  Future<Tag?> getTag(String id) async {
    return (await _source.getTag(id))?.toEntity();
  }

  @override
  Future<void> createTag(Tag tag) {
    return _source.insertTag(TagModel.fromEntity(tag));
  }

  @override
  Future<void> updateTag(Tag tag) {
    return _source.updateTag(TagModel.fromEntity(tag));
  }

  @override
  Future<void> upsertTag(Tag tag) {
    return _source.upsertTag(TagModel.fromEntity(tag));
  }

  @override
  Future<void> deleteTag(String id) {
    return _source.deleteTag(id);
  }

  @override
  Stream<List<Tag>> watchTagsForDevice(String deviceId) {
    return _source
        .watchTagsForDevice(deviceId)
        .map(
          (models) => models.map((m) => m.toEntity()).toList(growable: false),
        );
  }

  @override
  Future<List<Tag>> getTagsForDevice(String deviceId) async {
    final models = await _source.getTagsForDevice(deviceId);
    return models.map((m) => m.toEntity()).toList(growable: false);
  }

  @override
  Future<void> setDeviceTags(String deviceId, List<String> tagIds) {
    return _source.setDeviceTags(deviceId, tagIds);
  }

  @override
  Stream<List<DeviceTagLink>> watchDeviceTagLinks() {
    return _source.watchDeviceTagLinks();
  }

  @override
  Future<List<DeviceTagLink>> getDeviceTagLinks() {
    return _source.getDeviceTagLinks();
  }

  @override
  Future<void> upsertDeviceTagLink(DeviceTagLink link) {
    return _source.upsertDeviceTagLink(link);
  }

  @override
  Future<void> deleteLinksForDevice(String deviceId) {
    return _source.deleteLinksForDevice(deviceId);
  }
}
