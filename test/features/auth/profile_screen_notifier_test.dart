import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:med_sync/features/auth/data/auth_repository.dart';
import 'package:med_sync/features/auth/data/profile_repository.dart';
import 'package:med_sync/features/auth/models/user_profile.dart';
import 'package:med_sync/features/auth/state/auth_providers.dart';
import 'package:med_sync/features/auth/state/profile_screen_notifier.dart';

void main() {
  test('build loads user profile', () async {
    final container = ProviderContainer(
      overrides: [
        currentUserProvider.overrideWith((ref) => Stream.value(_FakeUser())),
        authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
        profileRepositoryProvider.overrideWithValue(_FakeProfileRepository()),
      ],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(profileScreenProvider, (_, _) {});
    addTearDown(subscription.close);

    final state = await container.read(profileScreenProvider.future);
    expect(state.profile.displayName, 'Raees');
    expect(state.isSubmitting, isFalse);
    expect(state.actionFailure, isNull);
  });

  test('updateDisplayName updates profile in state', () async {
    final repository = _FakeProfileRepository();
    final container = ProviderContainer(
      overrides: [
        currentUserProvider.overrideWith((ref) => Stream.value(_FakeUser())),
        authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
        profileRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(profileScreenProvider, (_, _) {});
    addTearDown(subscription.close);

    await container.read(profileScreenProvider.future);

    final success = await container
        .read(profileScreenProvider.notifier)
        .updateDisplayName('Updated Name');

    expect(success, isTrue);
    final state = container.read(profileScreenProvider).requireValue;
    expect(state.profile.displayName, 'Updated Name');
    expect(state.isSubmitting, isFalse);
  });

  test('updateDisplayName rejects empty name', () async {
    final container = ProviderContainer(
      overrides: [
        currentUserProvider.overrideWith((ref) => Stream.value(_FakeUser())),
        authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
        profileRepositoryProvider.overrideWithValue(_FakeProfileRepository()),
      ],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(profileScreenProvider, (_, _) {});
    addTearDown(subscription.close);

    await container.read(profileScreenProvider.future);

    final success = await container
        .read(profileScreenProvider.notifier)
        .updateDisplayName('   ');

    expect(success, isFalse);
    final state = container.read(profileScreenProvider).requireValue;
    expect(state.actionFailure, isNotNull);
    expect(state.actionFailure!.fieldErrors['displayName'], isNotNull);
  });

  test('updateDisplayName does not write state after disposal', () async {
    final repository = _DelayedProfileRepository();
    final container = ProviderContainer(
      overrides: [
        currentUserProvider.overrideWith((ref) => Stream.value(_FakeUser())),
        authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
        profileRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(profileScreenProvider, (_, _) {});
    addTearDown(subscription.close);

    await container.read(profileScreenProvider.future);

    final save = container
        .read(profileScreenProvider.notifier)
        .updateDisplayName('Updated Name');

    container.dispose();
    repository.completeSave();

    await expectLater(save, completes);
  });
}

class _FakeAuthRepository implements AuthRepository {
  final _user = _FakeUser();

  @override
  User? get currentUser => _user;

  @override
  Stream<User?> authStateChanges() => Stream.value(_user);

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) => throw UnimplementedError();
  @override
  Future<void> deleteCurrentUser() => throw UnimplementedError();
  @override
  Future<void> reauthenticateForDeletion({
    required UserProfile profile,
    String? password,
  }) => throw UnimplementedError();
  @override
  Future<void> reloadCurrentUser() => throw UnimplementedError();
  @override
  Future<void> sendEmailVerification() => throw UnimplementedError();
  @override
  Future<void> sendPasswordResetEmail(String email) =>
      throw UnimplementedError();
  @override
  Future<User> signInWithApple() => throw UnimplementedError();
  @override
  Future<User> signInWithEmail({
    required String email,
    required String password,
  }) => throw UnimplementedError();
  @override
  Future<User> signInWithGoogle() => throw UnimplementedError();
  @override
  Future<void> signOut() async {}
  @override
  Future<User> signUpWithEmail({
    required String displayName,
    required String email,
    required String password,
  }) => throw UnimplementedError();
}

class _FakeProfileRepository implements ProfileRepository {
  String _displayName = 'Raees';

  @override
  Future<UserProfile?> fetchProfile(String uid) async => _profile();

  @override
  Future<UserProfile> updateDisplayName({
    required User user,
    required String displayName,
  }) async {
    _displayName = displayName;
    return _profile();
  }

  @override
  Future<UserProfile> upsertFromFirebaseUser(User user) async => _profile();

  @override
  Future<void> deleteProfile(String uid) => throw UnimplementedError();

  UserProfile _profile() => UserProfile(
    uid: 'uid-1',
    displayName: _displayName,
    email: 'raees@example.com',
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
    lastLoginAt: DateTime(2026),
    providerIds: const ['password'],
    emailVerified: true,
  );
}

class _DelayedProfileRepository extends _FakeProfileRepository {
  final _completer = Completer<UserProfile>();

  void completeSave() {
    if (!_completer.isCompleted) {
      _completer.complete(_profile());
    }
  }

  @override
  Future<UserProfile> updateDisplayName({
    required User user,
    required String displayName,
  }) => _completer.future;
}

class _FakeUser extends Fake implements User {
  @override
  String get uid => 'uid-1';
  @override
  String? get displayName => 'Raees';
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
