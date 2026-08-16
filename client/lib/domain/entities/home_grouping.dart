enum HomeGrouping {
  device('device'),
  tag('tag');

  const HomeGrouping(this.storageValue);

  final String storageValue;

  static const defaultValue = HomeGrouping.device;

  static HomeGrouping fromStorage(String? value) {
    return switch (value) {
      'tag' => HomeGrouping.tag,
      _ => HomeGrouping.device,
    };
  }
}
