import 'package:med_sync/core/base_failure.dart';
import 'package:med_sync/core/errors/app_failure_mapper.dart';
import 'package:med_sync/core/logging/app_logger.dart';
import 'package:med_sync/features/auth/state/auth_providers.dart';
import 'package:med_sync/features/medications/models/medication.dart';
import 'package:med_sync/features/medications/models/medication_failure.dart';
import 'package:med_sync/features/medications/models/medication_form_state.dart';
import 'package:med_sync/features/medications/state/medication_form_validator.dart';
import 'package:med_sync/features/medications/state/medication_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part '../../../generated/features/medications/state/add_medication_controller.g.dart';

@riverpod
class AddMedicationController extends _$AddMedicationController {
  @override
  MedicationFormState build() => const MedicationFormState();

  void clearFailure() {
    state = state.copyWith(failure: null);
  }

  Future<String?> save(MedicationFormInput input) async {
    final validation = MedicationFormValidator.validate(input);
    if (!validation.isValid) {
      state = state.copyWith(
        failure: MedicationFailures.validation(validation.fieldErrors),
      );
      return null;
    }

    state = state.copyWith(isSubmitting: true, failure: null);

    try {
      final ownerUid = _currentUserUid();
      final medication = await ref
          .read(medicationRepositoryProvider)
          .createMedication(ownerUid: ownerUid, input: input);
      if (!ref.mounted) return null;
      ref.invalidate(medicationListProvider);
      state = state.copyWith(isSubmitting: false, failure: null);
      return medication.id;
    } on Object catch (error, stackTrace) {
      if (!ref.mounted) return null;
      state = state.copyWith(
        isSubmitting: false,
        failure: _mapFailure(error, stackTrace),
      );
      return null;
    }
  }

  String _currentUserUid() {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) throw MedicationFailures.missingSession();
    return user.uid;
  }

  BaseFailure _mapFailure(Object error, StackTrace stackTrace) {
    if (error is BaseFailure) return error;
    return AppFailureMapper.map(
      error,
      stackTrace: stackTrace,
      logger: ref.read(appLoggerProvider('medications.controller')),
    );
  }
}
