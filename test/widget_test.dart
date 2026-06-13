import 'package:firebase_auth_flutter/core/utils/auth_error_mapper.dart';
import 'package:firebase_auth_flutter/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validators', () {
    test('validates email', () {
      expect(Validators.validateEmail('student@example.com'), isNull);
      expect(Validators.validateEmail('student'), isNotNull);
    });

    test('validates matching passwords', () {
      expect(Validators.validateConfirmPassword('123456', '123456'), isNull);
      expect(Validators.validateConfirmPassword('123456', '654321'), isNotNull);
    });
  });

  test('maps Firebase auth errors', () {
    expect(
      AuthErrorMapper.messageFromCode('invalid-credential'),
      'Invalid email or password.',
    );
  });
}
