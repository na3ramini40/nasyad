import 'package:flutter_test/flutter_test.dart';

import 'package:nasyad/data/local/device_registration_store.dart';

void main() {
  group('DeviceRegistrationStore', () {
    test('getOrCreateDeviceId is stable across calls', () async {
      final store = DeviceRegistrationStore.memory();

      final first = await store.getOrCreateDeviceId();
      final second = await store.getOrCreateDeviceId();

      expect(first, isNotEmpty);
      expect(first.length, 32);
      expect(RegExp(r'^[0-9a-f]+$').hasMatch(first), isTrue);
      expect(second, first);
      expect(await store.readDeviceId(), first);
    });

    test('memory constructor seeds device_id', () async {
      final store = DeviceRegistrationStore.memory(deviceId: 'seeded-id');
      expect(await store.getOrCreateDeviceId(), 'seeded-id');
    });

    test('persists last synced fcm token', () async {
      final store = DeviceRegistrationStore.memory();
      expect(await store.readLastSyncedFcmToken(), isNull);

      await store.writeLastSyncedFcmToken('fcm-1');
      expect(await store.readLastSyncedFcmToken(), 'fcm-1');

      await store.writeLastSyncedFcmToken('fcm-2');
      expect(await store.readLastSyncedFcmToken(), 'fcm-2');
    });
  });
}
