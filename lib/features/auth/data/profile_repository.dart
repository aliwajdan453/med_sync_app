import 'package:firebase_auth/firebase_auth.dart';
import 'package:med_sync/features/auth/models/user_profile.dart';

abstract interface class ProfileRepository {
  Future<UserProfile?> fetchProfile(String uid);

  Future<UserProfile> upsertFromFirebaseUser(User user);

  Future<UserProfile> updateDisplayName({
    required User user,
    required String displayName,
  });

  Future<void> deleteProfile(String uid);
}
