import 'package:flutter_test/flutter_test.dart';
import 'package:med_sync/features/auth/state/auth_validators.dart';

void main() {
  group('AuthValidators', () {
    test('signup returns field errors for each invalid field', () {
      final failure = AuthValidators.validateSignup(
        displayName: '',
        email: 'bad',
        password: '123',
        confirmPassword: '456',
      );

      expect(failure, isNotNull);
      expect(failure!.title, 'Check fields');
      expect(failure.fieldErrors['displayName'], 'Enter your name.');
      expect(failure.fieldErrors['email'], 'Enter a valid email address.');
      expect(failure.fieldErrors['password'], 'Use at least 6 characters.');
      expect(failure.fieldErrors['confirmPassword'], 'Passwords do not match.');
    });

    test('login accepts a valid email and password', () {
      final failure = AuthValidators.validateLogin(
        email: 'person@example.com',
        password: 'secret1',
      );

      expect(failure, isNull);
    });

    test(
      'change password requires current password and confirmation match',
      () {
        final failure = AuthValidators.validateChangePassword(
          currentPassword: '',
          newPassword: 'secret1',
          confirmPassword: 'secret2',
        );

        expect(failure, isNotNull);
        expect(failure!.fieldErrors['currentPassword'], 'Enter your password.');
        expect(
          failure.fieldErrors['confirmPassword'],
          'Passwords do not match.',
        );
      },
    );
  });
}
