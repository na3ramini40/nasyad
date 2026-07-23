import 'dart:math';

abstract final class IdGenerator {
  static final Random _random = Random.secure();

  static String newId() {
    final millis = DateTime.now().toUtc().millisecondsSinceEpoch;
    final suffix = List.generate(8, (_) => _random.nextInt(16))
        .map((n) => n.toRadixString(16))
        .join();
    return '${millis.toRadixString(16)}$suffix';
  }
}
