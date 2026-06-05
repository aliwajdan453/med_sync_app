import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_sync/app/med_sync_app.dart';
import 'package:med_sync/features/auth/data/auth_repository.dart';
import 'package:med_sync/features/auth/models/user_profile.dart';
import 'package:med_sync/features/auth/state/auth_providers.dart';

void main() {
  testWidgets('renders signed out auth entry', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(_SignedOutAuthRepository()),
        ],
        child: const MedSyncApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Start your routine'), findsOneWidget);
    expect(find.text('Log in with email'), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
  });
}

class _SignedOutAuthRepository implements AuthRepository {
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
