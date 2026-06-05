import 'package:flutter_test/flutter_test.dart';
import 'package:med_sync/features/medications/data/firestore_medication_repository.dart';
import 'package:med_sync/features/medications/models/medication.dart';

void main() {
  test('sorts active medications newest first without a Firestore orderBy', () {
    final older = _medication(id: 'older', createdAt: DateTime(2026));
    final newer = _medication(id: 'newer', createdAt: DateTime(2026, 1, 2));

    final sorted = sortMedicationsNewestFirst(<Medication>[older, newer]);

    expect(sorted.map((medication) => medication.id), <String>[
      'newer',
      'older',
    ]);
  });
}

Medication _medication({required String id, required DateTime createdAt}) =>
    Medication(
      id: id,
      ownerUid: 'uid-1',
      name: id,
      category: MedicationCategory.supplement,
      routineType: MedicationRoutineType.asNeeded,
      status: MedicationStatus.active,
      doseAmount: 1,
      doseUnit: 'capsule',
      instructions: 'Use as needed.',
      createdAt: createdAt,
      updatedAt: createdAt,
    );
