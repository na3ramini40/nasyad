import 'package:flutter_test/flutter_test.dart';
import 'package:nasyad/core/preferences/home_grouping_preference_store.dart';
import 'package:nasyad/domain/entities/home_grouping.dart';

void main() {
  test('home grouping preference store round-trips', () async {
    final store = HomeGroupingPreferenceStore.memory();
    expect(await store.read(), HomeGrouping.device);

    await store.write(HomeGrouping.tag);
    expect(await store.read(), HomeGrouping.tag);

    await store.write(HomeGrouping.device);
    expect(await store.read(), HomeGrouping.device);
    store.dispose();
  });
}
