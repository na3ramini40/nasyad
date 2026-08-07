import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

/// Thin wrapper so tests can fake platform biometrics.
abstract class BiometricAuthenticator {
  Future<bool> isAvailable();

  Future<bool> authenticate({required String localizedReason});
}

class LocalBiometricAuthenticator implements BiometricAuthenticator {
  LocalBiometricAuthenticator({LocalAuthentication? auth})
    : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  @override
  Future<bool> isAvailable() async {
    try {
      final supported = await _auth.isDeviceSupported();
      if (!supported) return false;
      final canCheck = await _auth.canCheckBiometrics;
      if (!canCheck) return false;
      final types = await _auth.getAvailableBiometrics();
      return types.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> authenticate({required String localizedReason}) async {
    try {
      return await _auth.authenticate(
        localizedReason: localizedReason,
        persistAcrossBackgrounding: true,
      );
    } catch (error, stack) {
      debugPrint('Biometric authenticate failed: $error\n$stack');
      return false;
    }
  }
}

/// Always unavailable — used on unsupported platforms / tests.
class UnavailableBiometricAuthenticator implements BiometricAuthenticator {
  const UnavailableBiometricAuthenticator();

  @override
  Future<bool> isAvailable() async => false;

  @override
  Future<bool> authenticate({required String localizedReason}) async => false;
}
