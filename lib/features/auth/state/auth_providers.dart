import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:med_sync/core/logging/app_logger.dart';
import 'package:med_sync/features/auth/data/auth_repository.dart';
import 'package:med_sync/features/auth/data/firebase_auth_repository.dart';
import 'package:med_sync/features/auth/data/firestore_profile_repository.dart';
import 'package:med_sync/features/auth/data/profile_repository.dart';
import 'package:med_sync/features/auth/models/user_profile.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

part '../../../generated/features/auth/state/auth_providers.g.dart';

@Riverpod(keepAlive: true)
FirebaseAuth firebaseAuth(Ref ref) => FirebaseAuth.instance;

@Riverpod(keepAlive: true)
FirebaseFirestore firebaseFirestore(Ref ref) => FirebaseFirestore.instance;

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) => FirebaseAuthRepository(
  ref.read(firebaseAuthProvider),
  logger: ref.read(appLoggerProvider('auth.firebase')),
);

@Riverpod(keepAlive: true)
ProfileRepository profileRepository(Ref ref) => FirestoreProfileRepository(
  ref.read(firebaseFirestoreProvider),
  logger: ref.read(appLoggerProvider('auth.profile')),
);

@riverpod
Stream<User?> currentUser(Ref ref) =>
    ref.read(authRepositoryProvider).authStateChanges();

@riverpod
Future<UserProfile?> userProfile(Ref ref) async {
  final user = await ref.watch(currentUserProvider.future);

  if (user == null) return null;

  final repository = ref.read(profileRepositoryProvider);

  return await repository.fetchProfile(user.uid) ??
      repository.upsertFromFirebaseUser(user);
}

@riverpod
Future<bool> appleSignInAvailable(Ref ref) async {
  if (defaultTargetPlatform != TargetPlatform.iOS) return false;

  return SignInWithApple.isAvailable();
}
