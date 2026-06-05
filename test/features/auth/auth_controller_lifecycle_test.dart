import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_sync/features/auth/data/auth_repository.dart';
import 'package:med_sync/features/auth/data/profile_repository.dart';
import 'package:med_sync/features/auth/models/auth_form_state.dart';
import 'package:med_sync/features/auth/models/user_profile.dart';
import 'package:med_sync/features/auth/state/auth_controller.dart';
import 'package:med_sync/features/auth/state/auth_providers.dart';

void main() {
  test(
    'password reset does not write feedback state after controller disposal',
    () async {
      final authRepository = _DelayedPasswordResetRepository();
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepository),
          profileRepositoryProvider.overrideWithValue(
            _DelayedProfileRepository(),
          ),
        ],
      );

      final reset = container
          .read(authControllerProvider.notifier)
          .sendPasswordResetEmail(
            const PasswordResetFormInput(email: 'raees@example.com'),
          );

      container.dispose();
      authRepository.completePasswordReset();

      await expectLater(reset, completes);
    },
  );

  test(
    'verification resend does not write feedback state after controller disposal',
    () async {
      final authRepository = _DelayedVerificationRepository();
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepository),
          profileRepositoryProvider.overrideWithValue(
            _DelayedProfileRepository(),
          ),
        ],
      );

      final resend = container
          .read(authControllerProvider.notifier)
          .resendEmailVerification();

      container.dispose();
      authRepository.completeVerification();

      await expectLater(resend, completes);
    },
  );
}

class _CurrentUserRepository implements AuthRepository {
  final _user = _FakeUser();

  @override
  User? get currentUser => _user;

  @override
  Stream<User?> authStateChanges() => Stream<User?>.value(_user);

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteCurrentUser() {
    throw UnimplementedError();
  }

  @override
  Future<void> reauthenticateForDeletion({
    required UserProfile profile,
    String? password,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> reloadCurrentUser() {
    throw UnimplementedError();
  }

  @override
  Future<void> sendEmailVerification() {
    throw UnimplementedError();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) {
    throw UnimplementedError();
  }

  @override
  Future<User> signInWithApple() {
    throw UnimplementedError();
  }

  @override
  Future<User> signInWithEmail({
    required String email,
    required String password,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<User> signInWithGoogle() {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() {
    throw UnimplementedError();
  }

  @override
  Future<User> signUpWithEmail({
    required String displayName,
    required String email,
    required String password,
  }) {
    throw UnimplementedError();
  }
}

class _DelayedPasswordResetRepository extends _CurrentUserRepository {
  final _passwordResetCompleter = Completer<void>();

  void completePasswordReset() {
    _passwordResetCompleter.complete();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) =>
      _passwordResetCompleter.future;
}

class _DelayedVerificationRepository extends _CurrentUserRepository {
  final _verificationCompleter = Completer<void>();

  void completeVerification() {
    _verificationCompleter.complete();
  }

  @override
  Future<void> sendEmailVerification() => _verificationCompleter.future;
}

class _DelayedProfileRepository implements ProfileRepository {
  final _saveCompleter = Completer<UserProfile>();

  void completeSave() {
    _saveCompleter.complete(_profile(displayName: 'Updated Name'));
  }

  @override
  Future<void> deleteProfile(String uid) {
    throw UnimplementedError();
  }

  @override
  Future<UserProfile?> fetchProfile(String uid) async => _profile();

  @override
  Future<UserProfile> updateDisplayName({
    required User user,
    required String displayName,
  }) => _saveCompleter.future;

  @override
  Future<UserProfile> upsertFromFirebaseUser(User user) async => _profile();

  UserProfile _profile({String displayName = 'Original Name'}) => UserProfile(
    uid: 'uid-1',
    displayName: displayName,
    email: 'raees@example.com',
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
    lastLoginAt: DateTime(2026),
    providerIds: const ['password'],
    emailVerified: true,
  );
}

class _FakeUser extends Fake implements User {
  @override
  String get uid => 'uid-1';

  @override
  String? get displayName => 'Original Name';

  @override
  String? get email => 'raees@example.com';

  @override
  bool get emailVerified => true;

  @override
  List<UserInfo> get providerData => [_FakeUserInfo()];
}

class _FakeUserInfo extends Fake implements UserInfo {
  @override
  String get providerId => 'password';
}
