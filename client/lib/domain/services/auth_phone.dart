/// Pure helpers for phone OTP auth (testable without Flutter).
abstract final class AuthPhone {
  /// Normalize common IR mobile forms toward E.164 (`+98…`).
  /// Returns null when the input cannot be a usable phone.
  static String? normalize(String raw) {
    var digits = raw.trim().replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (digits.isEmpty) return null;

    if (digits.startsWith('00')) {
      digits = '+${digits.substring(2)}';
    }
    if (!digits.startsWith('+') &&
        digits.startsWith('98') &&
        digits.length >= 12) {
      digits = '+$digits';
    }
    if (!digits.startsWith('+') &&
        digits.startsWith('0') &&
        digits.length >= 10) {
      digits = '+98${digits.substring(1)}';
    }
    if (!digits.startsWith('+') && RegExp(r'^\d{10,15}$').hasMatch(digits)) {
      digits = '+$digits';
    }

    if (!RegExp(r'^\+[1-9]\d{7,14}$').hasMatch(digits)) {
      return null;
    }
    return digits;
  }

  static bool isValidOtpCode(String code) {
    return RegExp(r'^\d{4,8}$').hasMatch(code.trim());
  }
}

/// Tracks OTP resend cooldown remaining seconds.
class OtpCooldownTicker {
  OtpCooldownTicker({int initialSeconds = 0}) : _remaining = initialSeconds;

  int _remaining;

  int get remainingSeconds => _remaining;

  bool get canResend => _remaining <= 0;

  void start(int seconds) {
    _remaining = seconds < 0 ? 0 : seconds;
  }

  /// Advance one second; returns remaining after tick.
  int tick() {
    if (_remaining > 0) {
      _remaining -= 1;
    }
    return _remaining;
  }
}
