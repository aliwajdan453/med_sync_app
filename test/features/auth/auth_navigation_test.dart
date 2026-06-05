import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:med_sync/app/med_sync_app.dart';
import 'package:med_sync/core/base_failure.dart';
import 'package:med_sync/features/auth/data/auth_repository.dart';
import 'package:med_sync/features/auth/data/profile_repository.dart';
import 'package:med_sync/features/auth/models/user_profile.dart';
import 'package:med_sync/features/auth/state/auth_providers.dart';
import 'package:med_sync/features/medications/state/medication_providers.dart';
import 'package:med_sync/features/medications/data/medication_repository.dart';
import 'package:med_sync/features/medications/models/medication.dart';

void main() {
  testWidgets('clears login failure when opening forgot password', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(_FailingLoginRepository()),
        ],
        child: const MedSyncApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Log in with email'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'a@b.co');
    await tester.enterText(find.byType(TextField).at(1), 'secret1');
    await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
    await tester.pumpAndSettle();

    expect(find.text('The email or password is incorrect.'), findsOneWidget);
    expect(find.text('Check your password.'), findsNothing);

    await tester.tap(find.text('Forgot password?'));
    await tester.pumpAndSettle();

    expect(find.text('Reset password'), findsOneWidget);
    expect(find.text('The email or password is incorrect.'), findsNothing);
  });

  testWidgets('empty forgot password submit validates inline only', (
    tester,
  ) async {
    final authRepository = _CountingPasswordResetRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(authRepository)],
        child: const MedSyncApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Log in with email'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Forgot password?'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Send reset email'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a valid email address.'), findsOneWidget);
    expect(find.text('Check the highlighted fields.'), findsNothing);
    expect(authRepository.passwordResetCalls, 0);
  });

  testWidgets('invalid forgot password submit clears stale failure banner', (
    tester,
  ) async {
    final authRepository = _FailingPasswordResetRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(authRepository)],
        child: const MedSyncApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Log in with email'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Forgot password?'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'raees@example.com');
    await tester.tap(find.widgetWithText(FilledButton, 'Send reset email'));
    await tester.pumpAndSettle();

    expect(find.text('Reset failed.'), findsOneWidget);
    expect(authRepository.passwordResetCalls, 1);

    await tester.enterText(find.byType(TextField).first, 'bad');
    await tester.tap(find.widgetWithText(FilledButton, 'Send reset email'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a valid email address.'), findsOneWidget);
    expect(find.text('Reset failed.'), findsNothing);
    expect(find.text('Check the highlighted fields.'), findsNothing);
    expect(authRepository.passwordResetCalls, 1);
  });

  testWidgets('clears login field errors before opening signup', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(_FailingLoginRepository()),
        ],
        child: const MedSyncApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Log in with email'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a valid email address.'), findsOneWidget);
    expect(find.text('Enter your password.'), findsOneWidget);
    expect(find.text('Check the highlighted fields.'), findsNothing);

    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilledButton, 'Create account'), findsOneWidget);
    expect(find.text('Enter a valid email address.'), findsNothing);
    expect(find.text('Enter your password.'), findsNothing);
  });

  testWidgets('email login is pushed on top of auth landing', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(_FailingLoginRepository()),
        ],
        child: const MedSyncApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Log in with email'));
    await tester.pumpAndSettle();

    expect(find.text('Log in'), findsWidgets);
    expect(find.byTooltip('Back'), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.text('Start your routine'), findsOneWidget);
  });

  testWidgets('signup from login can pop back to login', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(_FailingLoginRepository()),
        ],
        child: const MedSyncApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Log in with email'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();

    expect(find.text('Create account'), findsWidgets);
    expect(find.byTooltip('Back'), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.text('Log in'), findsWidgets);
  });

  testWidgets('empty signup submit shows inline validators without banner', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(_FailingLoginRepository()),
        ],
        child: const MedSyncApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
    await tester.pumpAndSettle();

    expect(find.text('Enter your name.'), findsOneWidget);
    expect(find.text('Enter a valid email address.'), findsOneWidget);
    expect(find.text('Use at least 6 characters.'), findsOneWidget);
    expect(find.text('Check the highlighted fields.'), findsNothing);
  });

  testWidgets('signup backend failure stays in banner, not inline fields', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(_FailingSignupRepository()),
        ],
        child: const MedSyncApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'Raees');
    await tester.enterText(find.byType(TextField).at(1), 'raees@example.com');
    await tester.enterText(find.byType(TextField).at(2), 'secret1');
    await tester.enterText(find.byType(TextField).at(3), 'secret1');
    await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
    await tester.pumpAndSettle();

    expect(
      find.text('This email is already attached to an account.'),
      findsOneWidget,
    );
    expect(find.text('Use a different email.'), findsNothing);
  });

  testWidgets('signup auth stream update does not trigger provider assertion', (
    tester,
  ) async {
    final authRepository = _SigningUpRepository();
    addTearDown(authRepository.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepository),
          profileRepositoryProvider.overrideWithValue(_ProfileRepository()),
        ],
        child: const MedSyncApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'Raees');
    await tester.enterText(find.byType(TextField).at(1), 'raees@example.com');
    await tester.enterText(find.byType(TextField).at(2), 'secret1');
    await tester.enterText(find.byType(TextField).at(3), 'secret1');
    await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
    await tester.pumpAndSettle();

    expect(find.text('Verify your email'), findsOneWidget);
    expect(authRepository.authStateSubscriptionCount, 1);
    final exception = tester.takeException();
    expect(exception, isNull);
  });

  testWidgets('profile name save keeps the profile route mounted', (
    tester,
  ) async {
    final authRepository = _UpdatingProfileAuthRepository();
    final profileRepository = _UpdatingProfileRepository(
      onUpdate: authRepository.emitProfileUpdate,
    );
    addTearDown(authRepository.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepository),
          profileRepositoryProvider.overrideWithValue(profileRepository),
          medicationRepositoryProvider.overrideWithValue(
            _EmptyMedicationRepository(),
          ),
        ],
        child: const MedSyncApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Profile'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'Updated Name');
    await tester.tap(find.widgetWithText(FilledButton, 'Save name'));
    await tester.pumpAndSettle();

    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Updated Name'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty change password submit validates inline only', (
    tester,
  ) async {
    final authRepository = _ChangingPasswordAuthRepository();
    final profileRepository = _UpdatingProfileRepository(
      onUpdate: authRepository.emitProfileUpdate,
    );
    addTearDown(authRepository.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepository),
          profileRepositoryProvider.overrideWithValue(profileRepository),
          medicationRepositoryProvider.overrideWithValue(
            _EmptyMedicationRepository(),
          ),
        ],
        child: const MedSyncApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Profile'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Change password'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Update password'));
    await tester.pumpAndSettle();

    expect(find.text('Enter your password.'), findsOneWidget);
    expect(find.text('Use at least 6 characters.'), findsOneWidget);
    expect(find.text('Check the highlighted fields.'), findsNothing);
    expect(authRepository.changePasswordCalls, 0);
  });
}

class _EmptyMedicationRepository implements MedicationRepository {
  @override
  Stream<List<Medication>> watchActiveMedications(String ownerUid) =>
      Stream<List<Medication>>.value(const <Medication>[]);

  @override
  Stream<Medication?> watchMedication({
    required String ownerUid,
    required String medicationId,
  }) => Stream<Medication?>.value(null);

  @override
  Future<Medication> createMedication({
    required String ownerUid,
    required MedicationFormInput input,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> updateMedication({
    required String ownerUid,
    required String medicationId,
    required MedicationFormInput input,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> archiveMedication({
    required String ownerUid,
    required String medicationId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> permanentlyDeleteMedication({
    required String ownerUid,
    required String medicationId,
  }) {
    throw UnimplementedError();
  }
}

class _FailingLoginRepository implements AuthRepository {
  @override
  User? get currentUser => null;

  @override
  Stream<User?> authStateChanges() => Stream<User?>.value(null);

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
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  Future<User> signInWithApple() {
    throw UnimplementedError();
  }

  @override
  Future<User> signInWithEmail({
    required String email,
    required String password,
  }) {
    throw const BaseFailure(
      title: 'Sign in failed',
      description: 'The email or password is incorrect.',
      fieldErrors: {'password': 'Check your password.'},
    );
  }

  @override
  Future<User> signInWithGoogle() {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<User> signUpWithEmail({
    required String displayName,
    required String email,
    required String password,
  }) {
    throw UnimplementedError();
  }
}

class _CountingPasswordResetRepository extends _FailingLoginRepository {
  int passwordResetCalls = 0;

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    passwordResetCalls += 1;
  }
}

class _FailingPasswordResetRepository extends _CountingPasswordResetRepository {
  @override
  Future<void> sendPasswordResetEmail(String email) {
    passwordResetCalls += 1;
    throw const BaseFailure(
      title: 'Reset failed',
      description: 'Reset failed.',
    );
  }
}

class _FailingSignupRepository extends _FailingLoginRepository {
  @override
  Future<User> signUpWithEmail({
    required String displayName,
    required String email,
    required String password,
  }) {
    throw const BaseFailure(
      title: 'Account exists',
      description: 'This email is already attached to an account.',
      fieldErrors: {'email': 'Use a different email.'},
    );
  }
}

class _SigningUpRepository implements AuthRepository {
  final _controller = StreamController<User?>.broadcast();
  final _user = _FakeUser();
  User? _currentUser;
  int authStateSubscriptionCount = 0;

  Future<void> dispose() => _controller.close();

  @override
  User? get currentUser => _currentUser;

  @override
  Stream<User?> authStateChanges() async* {
    authStateSubscriptionCount += 1;
    yield _currentUser;
    yield* _controller.stream;
  }

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
  Future<void> reloadCurrentUser() async {}

  @override
  Future<void> sendEmailVerification() async {}

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

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
  Future<void> signOut() async {
    _currentUser = null;
    _controller.add(null);
  }

  @override
  Future<User> signUpWithEmail({
    required String displayName,
    required String email,
    required String password,
  }) async {
    _currentUser = _user;
    _controller.add(_user);
    return _user;
  }
}

class _ProfileRepository implements ProfileRepository {
  @override
  Future<void> deleteProfile(String uid) {
    throw UnimplementedError();
  }

  @override
  Future<UserProfile?> fetchProfile(String uid) async => null;

  @override
  Future<UserProfile> updateDisplayName({
    required User user,
    required String displayName,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<UserProfile> upsertFromFirebaseUser(User user) async => UserProfile(
    uid: user.uid,
    displayName: user.displayName ?? '',
    email: user.email ?? '',
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
    lastLoginAt: DateTime(2026),
    providerIds: user.providerData
        .map((provider) => provider.providerId)
        .toList(),
    emailVerified: user.emailVerified,
  );
}

class _UpdatingProfileAuthRepository implements AuthRepository {
  final _controller = StreamController<User?>.broadcast();
  final _user = _MutableFakeUser(
    displayName: 'Original Name',
    emailVerifiedValue: true,
  );

  Future<void> dispose() => _controller.close();

  void emitProfileUpdate(String displayName) {
    _user.displayNameValue = displayName;
    _controller.add(_user);
  }

  @override
  User? get currentUser => _user;

  @override
  Stream<User?> authStateChanges() async* {
    yield _user;
    yield* _controller.stream;
  }

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
  Future<void> reloadCurrentUser() async {}

  @override
  Future<void> sendEmailVerification() async {}

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
  Future<void> signOut() async {
    _controller.add(null);
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

class _ChangingPasswordAuthRepository extends _UpdatingProfileAuthRepository {
  int changePasswordCalls = 0;

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    changePasswordCalls += 1;
  }
}

class _UpdatingProfileRepository implements ProfileRepository {
  _UpdatingProfileRepository({required this.onUpdate});

  final void Function(String displayName) onUpdate;
  String _displayName = 'Original Name';

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
  }) async {
    _displayName = displayName;
    onUpdate(displayName);
    return _profile();
  }

  @override
  Future<UserProfile> upsertFromFirebaseUser(User user) async => _profile();

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

class _MutableFakeUser extends Fake implements User {
  _MutableFakeUser({
    required String displayName,
    required this.emailVerifiedValue,
  }) : displayNameValue = displayName;

  String displayNameValue;
  final bool emailVerifiedValue;

  @override
  String get uid => 'uid-1';

  @override
  String? get displayName => displayNameValue;

  @override
  String? get email => 'raees@example.com';

  @override
  bool get emailVerified => emailVerifiedValue;

  @override
  List<UserInfo> get providerData => [_FakeUserInfo()];
}

class _FakeUser extends Fake implements User {
  @override
  String get uid => 'uid-1';

  @override
  String? get displayName => 'Raees';

  @override
  String? get email => 'raees@example.com';

  @override
  bool get emailVerified => false;

  @override
  List<UserInfo> get providerData => [_FakeUserInfo()];
}

class _FakeUserInfo extends Fake implements UserInfo {
  @override
  String get providerId => 'password';
}
