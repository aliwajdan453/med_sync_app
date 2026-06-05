import 'package:med_sync/features/medications/models/medication.dart';

abstract interface class MedicationRepository {
  Stream<List<Medication>> watchActiveMedications(String ownerUid);

  Stream<Medication?> watchMedication({
    required String ownerUid,
    required String medicationId,
  });

  Future<Medication> createMedication({
    required String ownerUid,
    required MedicationFormInput input,
  });

  Future<void> updateMedication({
    required String ownerUid,
    required String medicationId,
    required MedicationFormInput input,
  });

  Future<void> archiveMedication({
    required String ownerUid,
    required String medicationId,
  });

  Future<void> permanentlyDeleteMedication({
    required String ownerUid,
    required String medicationId,
  });
}
