import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:med_sync/features/auth/data/auth_repository.dart';
import 'package:med_sync/features/auth/models/user_profile.dart';
import 'package:med_sync/features/medications/data/medication_repository.dart';
import 'package:med_sync/features/medications/models/medication.dart';

Medication fakeMedication({
  required String id,
  String ownerUid = 'uid-1',
  String name = 'Vitamin D',
}) => Medication(
  id: id,
  ownerUid: ownerUid,
  name: name,
  category: MedicationCategory.supplement,
  routineType: MedicationRoutineType.scheduled,
  status: MedicationStatus.active,
  doseAmount: 1,
  doseUnit: 'tablet',
  instructions: 'Take with breakfast.',
  schedule: const MedicationSchedule(
    pattern: MedicationSchedulePattern.daily,
    times: <MedicationTime>[MedicationTime(hour: 8, minute: 0)],
  ),
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

MedicationFormInput validMedicationInput() => const MedicationFormInput(
  name: 'Vitamin D',
  category: MedicationCategory.supplement,
  routineType: MedicationRoutineType.scheduled,
  doseAmount: 1,
  doseUnit: 'tablet',
  customDoseUnit: '',
  instructions: 'Take with breakfast.',
  schedule: MedicationSchedule(
    pattern: MedicationSchedulePattern.daily,
    times: <MedicationTime>[MedicationTime(hour: 8, minute: 0)],
  ),
  refillInfo: null,
);

class FakeMedicationRepository implements MedicationRepository {
  FakeMedicationRepository({this.error, this.medications = const []});

  final Exception? error;
  final List<Medication> medications;
  final List<Medication> created = <Medication>[];
  final List<String> archived = <String>[];
  final List<String> deleted = <String>[];

  @override
  Stream<List<Medication>> watchActiveMedications(String ownerUid) =>
      Stream.value(medications);

  @override
  Stream<Medication?> watchMedication({
    required String ownerUid,
    required String medicationId,
  }) => Stream.value(fakeMedication(id: medicationId));

  @override
  Future<Medication> createMedication({
    required String ownerUid,
    required MedicationFormInput input,
  }) async {
    final failure = error;
    if (failure != null) throw failure;
    final medication = fakeMedication(
      id: 'med-1',
      ownerUid: ownerUid,
      name: input.name,
    );
    created.add(medication);
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

class FakeAuthRepository implements AuthRepository {
  final _user = FakeUser();

  @override
  User? get currentUser => _user;

  @override
  Stream<User?> authStateChanges() => Stream<User?>.value(_user);

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

class FakeUser extends Fake implements User {
  @override
  String get uid => 'uid-1';

  @override
  String? get email => 'raees@example.com';

  @override
  bool get emailVerified => true;

  @override
  List<UserInfo> get providerData => <UserInfo>[FakeUserInfo()];
}

class FakeUserInfo extends Fake implements UserInfo {
  @override
  String get providerId => 'password';
}
