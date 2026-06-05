import 'package:flutter_test/flutter_test.dart';
import 'package:med_sync/features/auth/models/user_profile.dart';

void main() {
  group('UserProfile.deleteReauthMode', () {
    test('requires password for password-provider accounts', () {
      final profile = UserProfile(
        uid: 'u1',
        displayName: 'Ali',
        email: 'ali@example.com',
        providerIds: ['password'],
        emailVerified: true,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
        lastLoginAt: DateTime(2026),
      );

      expect(profile.deleteReauthMode, DeleteReauthMode.password);
    });

    test('uses provider reauth for social-only accounts', () {
      final profile = UserProfile(
        uid: 'u1',
        displayName: 'Ali',
        email: 'ali@example.com',
        providerIds: ['google.com'],
        emailVerified: true,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
        lastLoginAt: DateTime(2026),
      );

      expect(profile.deleteReauthMode, DeleteReauthMode.provider);
    });
  });
}
