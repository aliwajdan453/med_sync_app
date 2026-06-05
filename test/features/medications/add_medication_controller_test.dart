import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:med_sync/core/logging/app_logger.dart';
import 'package:med_sync/features/auth/state/auth_providers.dart';
import 'package:med_sync/features/medications/models/medication.dart';
import 'package:med_sync/features/medications/state/add_medication_controller.dart';
import 'package:med_sync/features/medications/state/medication_providers.dart';

import 'helpers/medication_test_helpers.dart';

void main() {
  test('save creates medication and returns its id', () async {
    final repository = FakeMedicationRepository();
    final container = ProviderContainer(
      overrides: [
        currentUserProvider.overrideWith((ref) => Stream.value(FakeUser())),
        authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
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
        .save(validMedicationInput());

    expect(medicationId, 'med-1');
    expect(repository.created.single.name, 'Vitamin D');
  });

  test('save returns null and sets failure when validation fails', () async {
    final container = ProviderContainer(
      overrides: [
        currentUserProvider.overrideWith((ref) => Stream.value(FakeUser())),
        authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
        medicationRepositoryProvider.overrideWithValue(
          FakeMedicationRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);
    container.listen(addMedicationControllerProvider, (_, _) {});

    const invalidInput = MedicationFormInput(
      name: '',
      category: MedicationCategory.supplement,
      routineType: MedicationRoutineType.scheduled,
      doseAmount: null,
      doseUnit: '',
      customDoseUnit: '',
      instructions: '',
      schedule: null,
      refillInfo: null,
    );

    final result = await container
        .read(addMedicationControllerProvider.notifier)
        .save(invalidInput);

    expect(result, isNull);
    final state = container.read(addMedicationControllerProvider);
    expect(state.failure, isNotNull);
    expect(state.fieldErrors['name'], 'Enter a medication name.');
  });

  test('save captures failure and logs when repository throws', () async {
    final repository = FakeMedicationRepository(
      error: Exception('firestore-down'),
    );
    final logger = _FakeLogger();
    final container = ProviderContainer(
      overrides: [
        currentUserProvider.overrideWith((ref) => Stream.value(FakeUser())),
        authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
        medicationRepositoryProvider.overrideWithValue(repository),
        appLoggerProvider('medications.controller').overrideWithValue(logger),
      ],
    );
    addTearDown(container.dispose);
    container.listen(addMedicationControllerProvider, (_, _) {});

    final medicationId = await container
        .read(addMedicationControllerProvider.notifier)
        .save(validMedicationInput());

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

  test('save does not write state after disposal', () async {
    final completer = Completer<void>();
    final repository = _DelayedFakeMedicationRepository(completer);
    final container = ProviderContainer(
      overrides: [
        currentUserProvider.overrideWith((ref) => Stream.value(FakeUser())),
        authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
        medicationRepositoryProvider.overrideWithValue(repository),
      ],
    )..listen(addMedicationControllerProvider, (_, _) {});

    final save = container
        .read(addMedicationControllerProvider.notifier)
        .save(validMedicationInput());

    container.dispose();
    completer.complete();

    await expectLater(save, completes);
  });
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

class _DelayedFakeMedicationRepository extends FakeMedicationRepository {
  _DelayedFakeMedicationRepository(this._completer);

  final Completer<void> _completer;

  @override
  Future<Medication> createMedication({
    required String ownerUid,
    required MedicationFormInput input,
  }) async {
    await _completer.future;
    return fakeMedication(id: 'med-1', ownerUid: ownerUid, name: input.name);
  }
}
