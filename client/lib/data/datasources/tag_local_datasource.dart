import 'package:nasyad/data/models/tag_model.dart';
import 'package:nasyad/domain/entities/device_tag_link.dart';

abstract class TagLocalDataSource {
  Stream<List<TagModel>> watchTags();

  Future<List<TagModel>> getAllTags();

  Future<TagModel?> getTag(String id);

  Future<void> insertTag(TagModel tag);

  Future<void> updateTag(TagModel tag);

  Future<void> upsertTag(TagModel tag);

  Future<void> deleteTag(String id);

  Stream<List<TagModel>> watchTagsForDevice(String deviceId);

  Future<List<TagModel>> getTagsForDevice(String deviceId);

  Future<void> setDeviceTags(String deviceId, List<String> tagIds);

  Stream<List<DeviceTagLink>> watchDeviceTagLinks();

  Future<List<DeviceTagLink>> getDeviceTagLinks();

  Future<void> upsertDeviceTagLink(DeviceTagLink link);

  Future<void> deleteLinksForDevice(String deviceId);
}
