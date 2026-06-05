import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_sync/core/routing/app_router.dart';
import 'package:med_sync/features/auth/data/auth_repository.dart';
import 'package:med_sync/features/auth/models/user_profile.dart';
import 'package:med_sync/features/auth/state/auth_providers.dart';

void main() {
  test('app router is not replaced when the current user updates', () async {
    final authRepository = _RouterAuthRepository();
    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(authRepository)],
    );
    addTearDown(container.dispose);
    addTearDown(authRepository.dispose);
    final subscription = container.listen(appRouterProvider, (_, _) {});
    addTearDown(subscription.close);

    final firstRouter = subscription.read();

    authRepository.emitUserUpdate();
    await Future<void>.delayed(Duration.zero);

    final secondRouter = subscription.read();

    expect(identical(firstRouter, secondRouter), isTrue);
  });
}

class _RouterAuthRepository implements AuthRepository {
  final _controller = StreamController<User?>.broadcast();
  final _user = _FakeUser();

  Future<void> dispose() => _controller.close();

  void emitUserUpdate() {
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
