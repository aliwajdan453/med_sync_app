import 'package:firebase_auth/firebase_auth.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_sync/app/med_sync_app.dart';
import 'package:med_sync/features/auth/data/auth_repository.dart';
import 'package:med_sync/features/auth/data/profile_repository.dart';
import 'package:med_sync/features/auth/models/user_profile.dart';
import 'package:med_sync/features/auth/state/auth_providers.dart';
import 'package:med_sync/features/medications/state/medication_providers.dart';
import 'package:med_sync/features/medications/data/medication_repository.dart';
import 'package:med_sync/features/medications/models/medication.dart';

void main() {
  testWidgets('bottom navigation switches between honest shell screens', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(_SignedInAuthRepository()),
          profileRepositoryProvider.overrideWithValue(_ProfileRepository()),
          medicationRepositoryProvider.overrideWithValue(
            _ScreenMedicationRepository(<Medication>[]),
          ),
        ],
        child: const MedSyncApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Today'), findsOneWidget);
    expect(find.text('No medications yet'), findsOneWidget);

    await tester.tap(find.text('Progress'));
    await tester.pumpAndSettle();
    expect(find.text('Progress'), findsWidgets);
    expect(
      find.text('Progress starts after scheduled dose tracking is added.'),
      findsOneWidget,
    );
    expect(find.textContaining('serum'), findsNothing);

    await tester.tap(find.text('Meds'));
    await tester.pumpAndSettle();
    expect(find.text('Medications'), findsOneWidget);
    expect(find.text('Add medication'), findsWidgets);
  });

  testWidgets('add medication validates visible fields before saving', (
    tester,
  ) async {
    final repository = _ScreenMedicationRepository(<Medication>[]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(_SignedInAuthRepository()),
          profileRepositoryProvider.overrideWithValue(_ProfileRepository()),
          medicationRepositoryProvider.overrideWithValue(repository),
        ],
        child: const MedSyncApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Add medication'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.widgetWithText(FilledButton, 'Save medication'),
      500,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Save medication'));
    await tester.pumpAndSettle();

    expect(
      find.text('Enter a medication name.', skipOffstage: false),
      findsOneWidget,
    );
    expect(repository.created, isEmpty);
  });
}

class _ScreenMedicationRepository implements MedicationRepository {
  _ScreenMedicationRepository(this.medications);

  final List<Medication> medications;
  final List<Medication> created = <Medication>[];

  @override
  Stream<List<Medication>> watchActiveMedications(String ownerUid) =>
      Stream<List<Medication>>.value(medications);

  @override
  Stream<Medication?> watchMedication({
    required String ownerUid,
    required String medicationId,
  }) => Stream<Medication?>.value(
    medications
        .where((medication) => medication.id == medicationId)
        .firstOrNull,
  );

  @override
  Future<Medication> createMedication({
    required String ownerUid,
    required MedicationFormInput input,
  }) async {
    final medication = Medication(
      id: 'med-${created.length + 1}',
      ownerUid: ownerUid,
      name: input.name.trim(),
      category: input.category,
      routineType: input.routineType,
      status: MedicationStatus.active,
      doseAmount: input.doseAmount ?? 0,
      doseUnit: input.doseUnit,
      instructions: input.instructions,
      schedule: input.schedule,
      refillInfo: input.refillInfo,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );
    created.add(medication);
    medications.add(medication);
    return medication;
  }

  @override
  Future<void> updateMedication({
    required String ownerUid,
    required String medicationId,
    required MedicationFormInput input,
  }) async {}

  @override
  Future<void> archiveMedication({
    required String ownerUid,
    required String medicationId,
  }) async {}

  @override
  Future<void> permanentlyDeleteMedication({
    required String ownerUid,
    required String medicationId,
  }) async {}
}

class _SignedInAuthRepository implements AuthRepository {
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

class _ProfileRepository implements ProfileRepository {
  @override
  Future<void> deleteProfile(String uid) {
    throw UnimplementedError();
  }

  @override
  Future<UserProfile?> fetchProfile(String uid) async => UserProfile(
    uid: uid,
    displayName: 'Raees',
    email: 'raees@example.com',
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
    lastLoginAt: DateTime(2026),
    providerIds: const <String>['password'],
    emailVerified: true,
  );

  @override
  Future<UserProfile> updateDisplayName({
    required User user,
    required String displayName,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<UserProfile> upsertFromFirebaseUser(User user) async =>
      (await fetchProfile(user.uid))!;
}

class _FakeUser extends Fake implements User {
  @override
  String get uid => 'uid-1';

  @override
  String? get email => 'raees@example.com';

  @override
  bool get emailVerified => true;

  @override
  List<UserInfo> get providerData => <UserInfo>[_FakeUserInfo()];
}

class _FakeUserInfo extends Fake implements UserInfo {
  @override
  String get providerId => 'password';
}
