import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:med_sync/core/base_failure.dart';
import 'package:med_sync/core/errors/app_failure_mapper.dart';
import 'package:med_sync/core/logging/app_logger.dart';
import 'package:med_sync/core/types.dart';
import 'package:med_sync/features/auth/data/profile_repository.dart';
import 'package:med_sync/features/auth/models/user_profile.dart';

class FirestoreProfileRepository implements ProfileRepository {
  FirestoreProfileRepository(this._firestore, {AppLogger? logger})
    : _logger = logger ?? const DeveloperAppLogger('auth.profile');

  final FirebaseFirestore _firestore;
  final AppLogger _logger;

  CollectionReference<Json> get _users => _firestore.collection('users');

  @override
  Future<UserProfile?> fetchProfile(String uid) async {
    try {
      final snapshot = await _users.doc(uid).get();
      final data = snapshot.data();
      if (data == null) {
        return null;
      }
      return UserProfile.fromJson(data);
    } on Object catch (error) {
      throw AppFailureMapper.map(error, logger: _logger);
    }
  }

  @override
  Future<UserProfile> upsertFromFirebaseUser(User user) async {
    try {
      final existing = await fetchProfile(user.uid);
      final now = DateTime.now();
      final profile = UserProfile(
        uid: user.uid,
        displayName: _displayNameFor(user, existing),
        email: user.email ?? existing?.email ?? '',
        photoUrl: user.photoURL ?? existing?.photoUrl,
        providerIds: _providerIdsFor(user),
        emailVerified: user.emailVerified,
        createdAt: existing?.createdAt ?? now,
        updatedAt: now,
        lastLoginAt: now,
      );

      await _users.doc(user.uid).set(profile.toJson(), SetOptions(merge: true));
      return profile;
    } on BaseFailure {
      rethrow;
    } on Object catch (error) {
      throw AppFailureMapper.map(error, logger: _logger);
    }
  }

  @override
  Future<UserProfile> updateDisplayName({
    required User user,
    required String displayName,
  }) async {
    try {
      final value = displayName.trim();
      await user.updateDisplayName(value);
      final existing = await fetchProfile(user.uid);
      final now = DateTime.now();
      final profile =
          (existing ??
                  UserProfile(
                    uid: user.uid,
                    displayName: value,
                    email: user.email ?? '',
                    photoUrl: user.photoURL,
                    providerIds: _providerIdsFor(user),
                    emailVerified: user.emailVerified,
                    createdAt: now,
                    updatedAt: now,
                    lastLoginAt: now,
                  ))
              .copyWith(displayName: value, updatedAt: now);

      await _users.doc(user.uid).set(profile.toJson(), SetOptions(merge: true));
      return profile;
    } on BaseFailure {
      rethrow;
    } on Object catch (error) {
      throw AppFailureMapper.map(error, logger: _logger);
    }
  }

  @override
  Future<void> deleteProfile(String uid) async {
    try {
      await _users.doc(uid).delete();
    } on Object catch (error) {
      throw AppFailureMapper.map(error, logger: _logger);
    }
  }

  static String _displayNameFor(User user, UserProfile? existing) {
    final firebaseName = user.displayName?.trim();
    if (firebaseName != null && firebaseName.isNotEmpty) {
      return firebaseName;
    }
    if (existing != null && existing.displayName.trim().isNotEmpty) {
      return existing.displayName;
    }
    final email = user.email;
    if (email != null && email.contains('@')) {
      return email.split('@').first;
    }
    return 'MedSync user';
  }

  static List<String> _providerIdsFor(User user) {
    final ids = user.providerData.map((info) => info.providerId).toSet();
    if (ids.isEmpty && user.email != null) {
      ids.add('password');
    }
    return ids.toList()..sort();
  }
}
