import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:med_sync/features/auth/data/auth_repository.dart';
import 'package:med_sync/features/auth/data/profile_repository.dart';
import 'package:med_sync/features/auth/models/user_profile.dart';
import 'package:med_sync/features/auth/state/auth_providers.dart';
import 'package:med_sync/features/auth/state/delete_account_screen_notifier.dart';

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
    final subscription = container.listen(
      deleteAccountScreenProvider,
      (_, _) {},
    );
    addTearDown(subscription.close);

    final state = await container.read(deleteAccountScreenProvider.future);
    expect(state.profile.hasPasswordProvider, isTrue);
    expect(state.isSubmitting, isFalse);
    expect(state.actionFailure, isNull);
  });

  test('deleteAccount validates password for password providers', () async {
    final container = ProviderContainer(
      overrides: [
        currentUserProvider.overrideWith((ref) => Stream.value(_FakeUser())),
        authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
        profileRepositoryProvider.overrideWithValue(_FakeProfileRepository()),
      ],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(
      deleteAccountScreenProvider,
      (_, _) {},
    );
    addTearDown(subscription.close);

    await container.read(deleteAccountScreenProvider.future);

    final success = await container
        .read(deleteAccountScreenProvider.notifier)
        .deleteAccount(password: '');

    expect(success, isFalse);
    final state = container.read(deleteAccountScreenProvider).requireValue;
    expect(state.actionFailure, isNotNull);
    expect(state.actionFailure!.fieldErrors['password'], isNotNull);
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
  Future<void> deleteCurrentUser() async {}
  @override
  Future<void> reauthenticateForDeletion({
    required UserProfile profile,
    String? password,
  }) async {}
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
  @override
  Future<UserProfile?> fetchProfile(String uid) async => _profile();
  @override
  Future<UserProfile> updateDisplayName({
    required User user,
    required String displayName,
  }) => throw UnimplementedError();
  @override
  Future<UserProfile> upsertFromFirebaseUser(User user) async => _profile();
  @override
  Future<void> deleteProfile(String uid) async {}

  UserProfile _profile() => UserProfile(
    uid: 'uid-1',
    displayName: 'Raees',
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
