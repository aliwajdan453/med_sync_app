import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:med_sync/features/auth/state/auth_providers.dart';
import 'package:med_sync/features/medications/models/medication.dart';
import 'package:med_sync/features/medications/state/medication_detail_screen_notifier.dart';
import 'package:med_sync/features/medications/state/medication_providers.dart';

import 'helpers/medication_test_helpers.dart';

ProviderContainer _buildContainer({FakeMedicationRepository? repository}) {
  final container = ProviderContainer(
    overrides: [
      currentUserProvider.overrideWith((ref) => Stream.value(FakeUser())),
      authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
      medicationRepositoryProvider.overrideWithValue(
        repository ?? FakeMedicationRepository(),
      ),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('build loads medication and returns initial state', () async {
    final container = _buildContainer();
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
    final container = _buildContainer()
      ..listen(medicationDetailScreenProvider('med-1'), (_, _) {});

    await container.read(medicationDetailScreenProvider('med-1').future);
    container
        .read(medicationDetailScreenProvider('med-1').notifier)
        .startEditing();

    final state = container
        .read(medicationDetailScreenProvider('med-1'))
        .requireValue;
    expect(state.isEditing, isTrue);
  });

  test('cancelEditing clears isEditing', () async {
    final container = _buildContainer()
      ..listen(medicationDetailScreenProvider('med-1'), (_, _) {});

    await container.read(medicationDetailScreenProvider('med-1').future);
    container
        .read(medicationDetailScreenProvider('med-1').notifier)
      ..startEditing()
      ..cancelEditing();

    final state = container
        .read(medicationDetailScreenProvider('med-1'))
        .requireValue;
    expect(state.isEditing, isFalse);
  });

  test('archive calls repository and returns true', () async {
    final repository = FakeMedicationRepository();
    final container = _buildContainer(repository: repository)
      ..listen(medicationDetailScreenProvider('med-1'), (_, _) {});

    await container.read(medicationDetailScreenProvider('med-1').future);
    final success = await container
        .read(medicationDetailScreenProvider('med-1').notifier)
        .archive();

    expect(success, isTrue);
    expect(repository.archived, contains('med-1'));
  });

  test('permanentlyDelete calls repository and sets didCompleteDelete', () async {
    final repository = FakeMedicationRepository();
    final container = _buildContainer(repository: repository)
      ..listen(medicationDetailScreenProvider('med-1'), (_, _) {});

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

  test('saveEdit with invalid input sets actionFailure and returns false',
      () async {
    final container = _buildContainer()
      ..listen(medicationDetailScreenProvider('med-1'), (_, _) {});

    await container.read(medicationDetailScreenProvider('med-1').future);
    final success = await container
        .read(medicationDetailScreenProvider('med-1').notifier)
        .saveEdit(
          const MedicationFormInput(
            name: '',
            category: MedicationCategory.supplement,
            routineType: MedicationRoutineType.scheduled,
            doseAmount: null,
            doseUnit: '',
            customDoseUnit: '',
            instructions: '',
            schedule: null,
            refillInfo: null,
          ),
        );

    expect(success, isFalse);
    final state = container
        .read(medicationDetailScreenProvider('med-1'))
        .requireValue;
    expect(state.actionFailure, isNotNull);
    expect(state.actionFailure!.fieldErrors['name'], 'Enter a medication name.');
  });
}
