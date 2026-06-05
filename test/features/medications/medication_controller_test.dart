import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:med_sync/core/logging/app_logger.dart';
import 'package:med_sync/features/auth/data/auth_repository.dart';
import 'package:med_sync/features/auth/models/user_profile.dart';
import 'package:med_sync/features/auth/state/auth_providers.dart';
import 'package:med_sync/features/medications/state/medication_controllers.dart';
import 'package:med_sync/features/medications/state/medication_providers.dart';
import 'package:med_sync/features/medications/data/medication_repository.dart';
import 'package:med_sync/features/medications/models/medication.dart';

void main() {
  test('add controller creates medication and records success state', () async {
    final repository = _FakeMedicationRepository();
    final container = ProviderContainer(
      overrides: [
        currentUserProvider.overrideWith((ref) => Stream.value(_FakeUser())),
        authRepositoryProvider.overrideWithValue(_ControllerAuthRepository()),
        medicationRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(
      addMedicationControllerProvider,
      (_, _) {},
    );
    addTearDown(subscription.close);

    final medicationId = await container
        .read(addMedicationControllerProvider.notifier)
        .save(_validInput());

    expect(medicationId, 'med-1');
    expect(repository.created.single.name, 'Vitamin D');
  });

  test('edit controller archives and permanently deletes medication', () async {
    final repository = _FakeMedicationRepository();
    final container = ProviderContainer(
      overrides: [
        currentUserProvider.overrideWith((ref) => Stream.value(_FakeUser())),
        authRepositoryProvider.overrideWithValue(_ControllerAuthRepository()),
        medicationRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(
      editMedicationControllerProvider('med-1'),
      (_, _) {},
    );
    addTearDown(subscription.close);

    final controller = container.read(
      editMedicationControllerProvider('med-1').notifier,
    );

    expect(await controller.archive(), isTrue);
    expect(await controller.permanentlyDelete(), isTrue);
    expect(repository.archived, <String>['med-1']);
    expect(repository.deleted, <String>['med-1']);
  });

  test('controller keeps diagnostics when repository throws', () async {
    final repository = _FakeMedicationRepository(
      error: Exception('firestore-down'),
    );
    final logger = _FakeLogger();
    final container = ProviderContainer(
      overrides: [
        currentUserProvider.overrideWith((ref) => Stream.value(_FakeUser())),
        authRepositoryProvider.overrideWithValue(_ControllerAuthRepository()),
        medicationRepositoryProvider.overrideWithValue(repository),
        appLoggerProvider('medications.controller').overrideWithValue(logger),
      ],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(
      addMedicationControllerProvider,
      (_, _) {},
    );
    addTearDown(subscription.close);

    final medicationId = await container
        .read(addMedicationControllerProvider.notifier)
        .save(_validInput());

    final state = container.read(addMedicationControllerProvider);
    expect(medicationId, isNull);
    expect(
      state.failure?.description,
      'We could not complete that request. Try again.',
    );
    expect(state.failure?.diagnosticMessage, contains('firestore-down'));
    expect(
      logger.errors.single.message,
      'Unhandled exception mapped to BaseFailure.',
    );
    expect(logger.errors.single.error.toString(), contains('firestore-down'));
    expect(logger.errors.single.stackTrace, isNotNull);
    expect(logger.errors.single.context['failureTitle'], 'Request failed');
  });

  test('controller does not write state after disposal', () async {
    final repository = _FakeMedicationRepository(delayCreate: true);
    final container = ProviderContainer(
      overrides: [
        currentUserProvider.overrideWith((ref) => Stream.value(_FakeUser())),
        authRepositoryProvider.overrideWithValue(_ControllerAuthRepository()),
        medicationRepositoryProvider.overrideWithValue(repository),
      ],
    );
    final subscription = container.listen(
      addMedicationControllerProvider,
      (_, _) {},
    );
    expect(subscription.read().isSubmitting, isFalse);

    final save = container
        .read(addMedicationControllerProvider.notifier)
        .save(_validInput());

    container.dispose();
    repository.completeCreate();

    await expectLater(save, completes);
  });
}

MedicationFormInput _validInput() => const MedicationFormInput(
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

class _FakeMedicationRepository implements MedicationRepository {
  _FakeMedicationRepository({this.error, this.delayCreate = false});

  final Exception? error;
  final bool delayCreate;
  final List<Medication> created = <Medication>[];
  final List<String> archived = <String>[];
  final List<String> deleted = <String>[];
  final Completer<Medication> _createCompleter = Completer<Medication>();

  void completeCreate() {
    if (!_createCompleter.isCompleted) {
      _createCompleter.complete(_medication(id: 'med-1'));
    }
  }

  @override
  Stream<List<Medication>> watchActiveMedications(String ownerUid) =>
      Stream.value(created);

  @override
  Stream<Medication?> watchMedication({
    required String ownerUid,
    required String medicationId,
  }) => Stream.value(_medication(id: medicationId));

  @override
  Future<Medication> createMedication({
    required String ownerUid,
    required MedicationFormInput input,
  }) async {
    final failure = error;
    if (failure != null) {
      throw failure;
    }
    if (delayCreate) {
      return _createCompleter.future;
    }
    final medication = _medication(
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

class _ControllerAuthRepository implements AuthRepository {
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

class _FakeLogger implements AppLogger {
  final errors = <_LogEntry>[];

  @override
  void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> context = const {},
  }) {
    errors.add(
      _LogEntry(
        message: message,
        error: error,
        stackTrace: stackTrace,
        context: context,
      ),
    );
  }

  @override
  void info(String message, {Map<String, Object?> context = const {}}) {}

  @override
  void warning(String message, {Map<String, Object?> context = const {}}) {}
}

class _LogEntry {
  const _LogEntry({
    required this.message,
    required this.error,
    required this.stackTrace,
    required this.context,
  });

  final String message;
  final Object? error;
  final StackTrace? stackTrace;
  final Map<String, Object?> context;
}

Medication _medication({
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
