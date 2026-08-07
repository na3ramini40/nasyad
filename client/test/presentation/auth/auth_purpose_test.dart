import 'package:flutter_test/flutter_test.dart';
import 'package:nasyad/presentation/auth/auth_purpose.dart';

void main() {
  test('AuthPurpose.resetLock matches query value', () {
    expect(AuthPurpose.isResetLock('reset_lock'), isTrue);
    expect(AuthPurpose.isResetLock(null), isFalse);
    expect(AuthPurpose.isResetLock('sign_in'), isFalse);
  });
}
