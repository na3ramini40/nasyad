import 'package:nasyad/domain/entities/device.dart';
import 'package:nasyad/domain/entities/search_results.dart';
import 'package:nasyad/domain/repositories/birthday_repository.dart';
import 'package:nasyad/domain/repositories/device_repository.dart';

class SearchUsecase {
  SearchUsecase(this._devices, this._birthdays);

  final DeviceRepository _devices;
  final BirthdayRepository _birthdays;

  Future<SearchResults> call(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return const SearchResults(devices: [], birthdays: []);
    }

    final deviceMatches = await _devices.searchActiveDevicesByName(trimmed);
    final allActive = await _devices.getDevices();
    final byId = {for (final device in allActive) device.id: device};

    final deviceHits = deviceMatches
        .map(
          (device) => DeviceSearchHit(
            device: device,
            pathSegments: _devicePathSegments(device, byId),
          ),
        )
        .toList(growable: false);

    final birthdays = await _birthdays.searchBirthdaysByName(trimmed);

    return SearchResults(devices: deviceHits, birthdays: birthdays);
  }

  List<String> _devicePathSegments(Device device, Map<String, Device> byId) {
    final segments = <String>[];
    var current = device;
    while (true) {
      segments.insert(0, current.name);
      final parentId = current.parentId;
      if (parentId == null) break;
      final parent = byId[parentId];
      if (parent == null) break;
      current = parent;
    }
    return segments;
  }
}
