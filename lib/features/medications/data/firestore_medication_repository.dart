import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:med_sync/core/base_failure.dart';
import 'package:med_sync/core/errors/app_failure_mapper.dart';
import 'package:med_sync/core/logging/app_logger.dart';
import 'package:med_sync/core/types.dart';
import 'package:med_sync/features/medications/data/medication_repository.dart';
import 'package:med_sync/features/medications/models/medication.dart';
import 'package:med_sync/features/medications/models/medication_failure.dart';
import 'package:med_sync/features/medications/state/medication_form_validator.dart';

class FirestoreMedicationRepository implements MedicationRepository {
  FirestoreMedicationRepository(this._firestore, {AppLogger? logger})
    : _logger = logger ?? const DeveloperAppLogger('medications.firestore');

  final FirebaseFirestore _firestore;
  final AppLogger _logger;

  CollectionReference<Json> _collection(String ownerUid) =>
      _firestore.collection('users').doc(ownerUid).collection('medications');

  @override
  Stream<List<Medication>> watchActiveMedications(String ownerUid) =>
      _collection(ownerUid)
          .where('status', isEqualTo: MedicationStatus.active.name)
          .snapshots()
          .map(
            (snapshot) => sortMedicationsNewestFirst(
              snapshot.docs
                  .map((doc) => Medication.fromJson({'id': doc.id, ...doc.data()}))
                  .toList(growable: false),
            ),
          );

  @override
  Stream<Medication?> watchMedication({
    required String ownerUid,
    required String medicationId,
  }) => _collection(ownerUid).doc(medicationId).snapshots().map((snapshot) {
    final data = snapshot.data();
    return data == null
        ? null
        : Medication.fromJson({'id': snapshot.id, ...data});
  });

  @override
  Future<Medication> createMedication({
    required String ownerUid,
    required MedicationFormInput input,
  }) async {
    try {
      final doc = _collection(ownerUid).doc();
      final now = DateTime.now();
      _logger.info(
        'Creating medication document.',
        context: <String, Object?>{
          'ownerUid': ownerUid,
          'medicationId': doc.id,
          'path': doc.path,
          'routineType': input.routineType.name,
          'category': input.category.name,
        },
      );
      final medication = _fromInput(
        id: doc.id,
        ownerUid: ownerUid,
        input: input,
        createdAt: now,
        updatedAt: now,
      );
      await doc.set(medication.toJson());
      _logger.info(
        'Medication document created.',
        context: <String, Object?>{
          'ownerUid': ownerUid,
          'medicationId': doc.id,
          'path': doc.path,
        },
      );
      return medication;
    } on BaseFailure {
      rethrow;
    } on Object catch (error, stackTrace) {
      _logger.error(
        'Medication document create failed.',
        error: error,
        stackTrace: stackTrace,
        context: <String, Object?>{'ownerUid': ownerUid},
      );
      throw AppFailureMapper.map(
        error,
        stackTrace: stackTrace,
        logger: _logger,
      );
    }
  }

  @override
  Future<void> updateMedication({
    required String ownerUid,
    required String medicationId,
    required MedicationFormInput input,
  }) async {
    try {
      final existing = await _collection(ownerUid).doc(medicationId).get();
      final data = existing.data();
      if (data == null) {
        throw MedicationFailures.missingMedication();
      }
      final current = Medication.fromJson({'id': existing.id, ...data});
      final updated = _fromInput(
        id: medicationId,
        ownerUid: ownerUid,
        input: input,
        createdAt: current.createdAt,
        updatedAt: DateTime.now(),
      ).copyWith(status: current.status, archivedAt: current.archivedAt);
      final doc = _collection(ownerUid).doc(medicationId);
      _logger.info(
        'Updating medication document.',
        context: <String, Object?>{
          'ownerUid': ownerUid,
          'medicationId': medicationId,
          'path': doc.path,
        },
      );
      await doc.set(updated.toJson(), SetOptions(merge: true));
    } on BaseFailure {
      rethrow;
    } on Object catch (error, stackTrace) {
      _logger.error(
        'Medication document update failed.',
        error: error,
        stackTrace: stackTrace,
        context: <String, Object?>{
          'ownerUid': ownerUid,
          'medicationId': medicationId,
        },
      );
      throw AppFailureMapper.map(
        error,
        stackTrace: stackTrace,
        logger: _logger,
      );
    }
  }

  @override
  Future<void> archiveMedication({
    required String ownerUid,
    required String medicationId,
  }) async {
    try {
      final now = DateTime.now();
      final doc = _collection(ownerUid).doc(medicationId);
      _logger.info(
        'Archiving medication document.',
        context: <String, Object?>{
          'ownerUid': ownerUid,
          'medicationId': medicationId,
          'path': doc.path,
        },
      );
      await doc.set(<String, Object?>{
        'status': MedicationStatus.archived.name,
        'archivedAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      }, SetOptions(merge: true));
    } on Object catch (error, stackTrace) {
      _logger.error(
        'Medication document archive failed.',
        error: error,
        stackTrace: stackTrace,
        context: <String, Object?>{
          'ownerUid': ownerUid,
          'medicationId': medicationId,
        },
      );
      throw AppFailureMapper.map(
        error,
        stackTrace: stackTrace,
        logger: _logger,
      );
    }
  }

  @override
  Future<void> permanentlyDeleteMedication({
    required String ownerUid,
    required String medicationId,
  }) async {
    try {
      final doc = _collection(ownerUid).doc(medicationId);
      _logger.warning(
        'Permanently deleting medication document.',
        context: <String, Object?>{
          'ownerUid': ownerUid,
          'medicationId': medicationId,
          'path': doc.path,
        },
      );
      await doc.delete();
    } on Object catch (error, stackTrace) {
      _logger.error(
        'Medication document delete failed.',
        error: error,
        stackTrace: stackTrace,
        context: <String, Object?>{
          'ownerUid': ownerUid,
          'medicationId': medicationId,
        },
      );
      throw AppFailureMapper.map(
        error,
        stackTrace: stackTrace,
        logger: _logger,
      );
    }
  }

  Medication _fromInput({
    required String id,
    required String ownerUid,
    required MedicationFormInput input,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) => Medication(
    id: id,
    ownerUid: ownerUid,
    name: input.name.trim(),
    category: input.category,
    routineType: input.routineType,
    status: MedicationStatus.active,
    doseAmount: input.doseAmount ?? 0,
    doseUnit: MedicationFormValidator.resolvedDoseUnit(input),
    instructions: input.instructions.trim(),
    schedule: input.routineType == MedicationRoutineType.scheduled
        ? input.schedule
        : null,
    refillInfo: input.refillInfo,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

List<Medication> sortMedicationsNewestFirst(List<Medication> medications) {
  final sorted = [...medications];
  return sorted
    ..sort((left, right) => right.createdAt.compareTo(left.createdAt));
}
