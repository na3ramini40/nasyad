import 'dart:async';
import 'dart:io';

/// Reads whether the device currently appears to have network connectivity.
///
/// Injectable so tests can use [AlwaysOnlineNetworkStatus] /
/// [OfflineNetworkStatus] without platform DNS lookups.
abstract class NetworkStatusReader {
  Future<bool> get isOnline;
}

/// Always reports online — useful in tests and when connectivity is assumed.
class AlwaysOnlineNetworkStatus implements NetworkStatusReader {
  const AlwaysOnlineNetworkStatus();

  @override
  Future<bool> get isOnline async => true;
}

/// Always reports offline — useful in tests.
class OfflineNetworkStatus implements NetworkStatusReader {
  const OfflineNetworkStatus();

  @override
  Future<bool> get isOnline async => false;
}

/// Conservative online check via a short DNS lookup.
///
/// Failure or timeout → offline. Not a guarantee of server reachability;
/// only gates whether remote sync may be *attempted*.
class LookupNetworkStatusReader implements NetworkStatusReader {
  LookupNetworkStatusReader({
    this.host = 'example.com',
    this.timeout = const Duration(seconds: 2),
    Future<List<InternetAddress>> Function(String host)? lookup,
  }) : _lookup = lookup ?? InternetAddress.lookup;

  final String host;
  final Duration timeout;
  final Future<List<InternetAddress>> Function(String host) _lookup;

  @override
  Future<bool> get isOnline async {
    try {
      final results = await _lookup(host).timeout(timeout);
      return results.isNotEmpty;
    } on SocketException {
      return false;
    } on TimeoutException {
      return false;
    } on OSError {
      return false;
    }
  }
}
