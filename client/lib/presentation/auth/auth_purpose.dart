/// Query values for `/auth/phone` and `/auth/otp`.
abstract final class AuthPurpose {
  /// OTP success clears local app-lock settings (identity proof).
  static const resetLock = 'reset_lock';

  static bool isResetLock(String? purpose) => purpose == resetLock;
}
