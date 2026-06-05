import 'package:firebase_auth/firebase_auth.dart';
import 'package:med_sync/features/auth/models/user_profile.dart';

abstract interface class AuthRepository {
  Stream<User?> authStateChanges();

  User? get currentUser;

  Future<User> signUpWithEmail({
    required String displayName,
    required String email,
    required String password,
  });

  Future<User> signInWithEmail({
    required String email,
    required String password,
  });

  Future<User> signInWithGoogle();

  Future<User> signInWithApple();

  Future<void> sendPasswordResetEmail(String email);

  Future<void> sendEmailVerification();

  Future<void> reloadCurrentUser();

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<void> reauthenticateForDeletion({
    required UserProfile profile,
    String? password,
  });

  Future<void> deleteCurrentUser();

  Future<void> signOut();
}
