import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:med_sync/features/auth/data/auth_repository.dart';
import 'package:med_sync/features/auth/models/user_profile.dart';
import 'package:med_sync/features/auth/state/auth_providers.dart';
import 'package:med_sync/features/medications/data/medication_repository.dart';
import 'package:med_sync/features/medications/models/medication.dart';
import 'package:med_sync/features/medications/state/medication_controllers.dart';
import 'package:med_sync/features/medications/state/medication_providers.dart';

void main() {
  test('build loads medication and returns initial state', () async {
    final repository = _FakeMedicationRepository();
    final container = ProviderContainer(
      overrides: [
        currentUserProvider.overrideWith((ref) => Stream.value(_FakeUser())),
        authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
        medicationRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(
      medicationDetailScreenProvider('med-1'),
      (_, _) {},
    );
    addTearDown(subscription.close);

    final state = await container.read(
      medicationDetailScreenProvider('med-1').future,
    );
    expect(state.medication.id, 'med-1');
    expect(state.isEditing, isFalse);
    expect(state.isSubmitting, isFalse);
    expect(state.actionFailure, isNull);
  });

  test('startEditing sets isEditing to true', () async {
    final container = ProviderContainer(
      overrides: [
        currentUserProvider.overrideWith((ref) => Stream.value(_FakeUser())),
        authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
        medicationRepositoryProvider.overrideWithValue(
          _FakeMedicationRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(
      medicationDetailScreenProvider('med-1'),
      (_, _) {},
    );
    addTearDown(subscription.close);

    await container.read(medicationDetailScreenProvider('med-1').future);
    container
        .read(medicationDetailScreenProvider('med-1').notifier)
        .startEditing();

    final state = container
        .read(medicationDetailScreenProvider('med-1'))
        .requireValue;
    expect(state.isEditing, isTrue);
  });

  test('archive calls repository and returns true', () async {
    final repository = _FakeMedicationRepository();
    final container = ProviderContainer(
      overrides: [
        currentUserProvider.overrideWith((ref) => Stream.value(_FakeUser())),
        authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
        medicationRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(
      medicationDetailScreenProvider('med-1'),
      (_, _) {},
    );
    addTearDown(subscription.close);

    await container.read(medicationDetailScreenProvider('med-1').future);
    final success = await container
        .read(medicationDetailScreenProvider('med-1').notifier)
        .archive();

    expect(success, isTrue);
    expect(repository.archived, contains('med-1'));
  });

  test('permanentlyDelete sets didCompleteDelete', () async {
    final repository = _FakeMedicationRepository();
    final container = ProviderContainer(
      overrides: [
        currentUserProvider.overrideWith((ref) => Stream.value(_FakeUser())),
        authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
        medicationRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(
      medicationDetailScreenProvider('med-1'),
      (_, _) {},
    );
    addTearDown(subscription.close);

    await container.read(medicationDetailScreenProvider('med-1').future);
    final success = await container
        .read(medicationDetailScreenProvider('med-1').notifier)
        .permanentlyDelete();

    expect(success, isTrue);
    expect(repository.deleted, contains('med-1'));
    final state = container
        .read(medicationDetailScreenProvider('med-1'))
        .requireValue;
    expect(state.didCompleteDelete, isTrue);
  });
}

class _FakeMedicationRepository implements MedicationRepository {
  final List<String> archived = [];
  final List<String> deleted = [];

  @override
  Stream<List<Medication>> watchActiveMedications(String ownerUid) =>
      Stream.value([]);

  @override
  Stream<Medication?> watchMedication({
    required String ownerUid,
    required String medicationId,
  }) => Stream.value(_medication(id: medicationId));

  @override
  Future<Medication> createMedication({
    required String ownerUid,
    required MedicationFormInput input,
  }) => throw UnimplementedError();

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
  }) async {
    archived.add(medicationId);
  }

  @override
  Future<void> permanentlyDeleteMedication({
    required String ownerUid,
    required String medicationId,
  }) async {
    deleted.add(medicationId);
  }
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
  Future<void> signOut() => throw UnimplementedError();
  @override
  Future<User> signUpWithEmail({
    required String displayName,
    required String email,
    required String password,
  }) => throw UnimplementedError();
}

Medication _medication({required String id}) => Medication(
  id: id,
  ownerUid: 'uid-1',
  name: 'Vitamin D',
  category: MedicationCategory.supplement,
  routineType: MedicationRoutineType.scheduled,
  status: MedicationStatus.active,
  doseAmount: 1,
  doseUnit: 'tablet',
  instructions: '',
  schedule: const MedicationSchedule(
    pattern: MedicationSchedulePattern.daily,
    times: [MedicationTime(hour: 8, minute: 0)],
  ),
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

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
