import 'package:nasyad/data/models/device_tag_link_model.dart';
import 'package:nasyad/data/models/tag_model.dart';

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

  Stream<List<DeviceTagLinkModel>> watchDeviceTagLinks();

  Future<List<DeviceTagLinkModel>> getDeviceTagLinks();

  Future<DeviceTagLinkModel?> getDeviceTagLink(String deviceId, String tagId);

  Future<void> upsertDeviceTagLink(DeviceTagLinkModel link);

  Future<void> deleteLinksForDevice(String deviceId);
}
