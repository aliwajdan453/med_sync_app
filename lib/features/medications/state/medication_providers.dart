import 'package:med_sync/core/logging/app_logger.dart';
import 'package:med_sync/features/auth/state/auth_providers.dart';
import 'package:med_sync/features/medications/data/firestore_medication_repository.dart';
import 'package:med_sync/features/medications/data/medication_repository.dart';
import 'package:med_sync/features/medications/models/medication.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part '../../../generated/features/medications/state/medication_providers.g.dart';

@Riverpod(keepAlive: true)
MedicationRepository medicationRepository(Ref ref) =>
    FirestoreMedicationRepository(
      ref.read(firebaseFirestoreProvider),
      logger: ref.read(appLoggerProvider('medications.firestore')),
    );

@riverpod
Stream<List<Medication>> medicationList(Ref ref) async* {
  final user = await ref.watch(currentUserProvider.future);

  if (user == null) {
    yield const <Medication>[];
    return;
  }

  yield* ref
      .read(medicationRepositoryProvider)
      .watchActiveMedications(user.uid);
}

@riverpod
Stream<Medication?> medicationDetail(Ref ref, String medicationId) async* {
  final user = await ref.watch(currentUserProvider.future);

  if (user == null) {
    yield null;
    return;
  }

  yield* ref
      .read(medicationRepositoryProvider)
      .watchMedication(ownerUid: user.uid, medicationId: medicationId);
}
