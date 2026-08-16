import 'package:nasyad/domain/entities/device_tag_link.dart';
import 'package:nasyad/domain/entities/tag.dart';

abstract class TagRepository {
  Stream<List<Tag>> watchTags();

  Future<List<Tag>> getAllTags();

  Future<Tag?> getTag(String id);

  Future<void> createTag(Tag tag);

  Future<void> updateTag(Tag tag);

  Future<void> upsertTag(Tag tag);

  Future<void> deleteTag(String id);

  Stream<List<Tag>> watchTagsForDevice(String deviceId);

  Future<List<Tag>> getTagsForDevice(String deviceId);

  Future<void> setDeviceTags(String deviceId, List<String> tagIds);

  Stream<List<DeviceTagLink>> watchDeviceTagLinks();

  Future<List<DeviceTagLink>> getDeviceTagLinks();

  Future<void> upsertDeviceTagLink(DeviceTagLink link);

  Future<void> deleteLinksForDevice(String deviceId);
}
