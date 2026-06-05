import 'package:med_sync/core/base_failure.dart';
import 'package:med_sync/core/errors/app_failure_mapper.dart';
import 'package:med_sync/core/logging/app_logger.dart';
import 'package:med_sync/features/auth/state/auth_providers.dart';
import 'package:med_sync/features/medications/models/medication.dart';
import 'package:med_sync/features/medications/models/medication_detail_state.dart';
import 'package:med_sync/features/medications/models/medication_failure.dart';
import 'package:med_sync/features/medications/models/medication_form_state.dart';
import 'package:med_sync/features/medications/state/medication_form_validator.dart';
import 'package:med_sync/features/medications/state/medication_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part '../../../generated/features/medications/state/medication_controllers.g.dart';

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
        failure: _mapFailure(
          error,
          stackTrace,
          ref.read(appLoggerProvider('medications.controller')),
        ),
      );
      return null;
    }
  }

  String _currentUserUid() {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) throw MedicationFailures.missingSession();
    return user.uid;
  }
}

@riverpod
class EditMedicationController extends _$EditMedicationController {
  @override
  MedicationFormState build(String medicationId) => const MedicationFormState();

  void clearFailure() {
    state = state.copyWith(failure: null);
  }

  Future<bool> save(MedicationFormInput input) async {
    final validation = MedicationFormValidator.validate(input);
    if (!validation.isValid) {
      state = state.copyWith(
        failure: MedicationFailures.validation(validation.fieldErrors),
      );
      return false;
    }

    return _submit(() async {
      final ownerUid = _currentUserUid();
      await ref
          .read(medicationRepositoryProvider)
          .updateMedication(
            ownerUid: ownerUid,
            medicationId: medicationId,
            input: input,
          );
      ref
        ..invalidate(medicationListProvider)
        ..invalidate(medicationDetailProvider(medicationId));
    });
  }

  Future<bool> archive() => _submit(() async {
    final ownerUid = _currentUserUid();
    await ref
        .read(medicationRepositoryProvider)
        .archiveMedication(ownerUid: ownerUid, medicationId: medicationId);
    ref
      ..invalidate(medicationListProvider)
      ..invalidate(medicationDetailProvider(medicationId));
  });

  Future<bool> permanentlyDelete() => _submit(() async {
    final ownerUid = _currentUserUid();
    await ref
        .read(medicationRepositoryProvider)
        .permanentlyDeleteMedication(
          ownerUid: ownerUid,
          medicationId: medicationId,
        );
    ref
      ..invalidate(medicationListProvider)
      ..invalidate(medicationDetailProvider(medicationId));
    state = state.copyWith(didCompleteDelete: true);
  });

  Future<bool> _submit(Future<void> Function() action) async {
    state = state.copyWith(isSubmitting: true, failure: null);

    try {
      await action();
      if (!ref.mounted) return true;
      state = state.copyWith(isSubmitting: false, failure: null);
      return true;
    } on Object catch (error, stackTrace) {
      if (!ref.mounted) return false;
      state = state.copyWith(
        isSubmitting: false,
        failure: _mapFailure(
          error,
          stackTrace,
          ref.read(appLoggerProvider('medications.controller')),
        ),
      );
      return false;
    }
  }

  String _currentUserUid() {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) throw MedicationFailures.missingSession();
    return user.uid;
  }
}

@riverpod
class MedicationDetailScreenNotifier extends _$MedicationDetailScreenNotifier {
  @override
  Future<MedicationDetailState> build(String medicationId) async {
    final user = await ref.watch(currentUserProvider.future);
    if (user == null) throw MedicationFailures.missingSession();

    ref.listen(medicationDetailProvider(medicationId), (_, next) {
      if (!ref.mounted) return;
      next.whenData((medication) {
        if (medication == null || !state.hasValue) return;
        state = AsyncData(state.requireValue.copyWith(medication: medication));
      });
    });

    final medication = await ref.read(
      medicationDetailProvider(medicationId).future,
    );
    if (medication == null) throw MedicationFailures.missingMedication();
    return MedicationDetailState(medication: medication);
  }

  void startEditing() {
    if (!state.hasValue) return;
    state = AsyncData(
      state.requireValue.copyWith(isEditing: true, actionFailure: null),
    );
  }

  void cancelEditing() {
    if (!state.hasValue) return;
    state = AsyncData(
      state.requireValue.copyWith(isEditing: false, actionFailure: null),
    );
  }

  Future<bool> saveEdit(MedicationFormInput input) async {
    if (!state.hasValue) return false;
    final validation = MedicationFormValidator.validate(input);
    if (!validation.isValid) {
      state = AsyncData(
        state.requireValue.copyWith(
          actionFailure: MedicationFailures.validation(validation.fieldErrors),
        ),
      );
      return false;
    }

    state = AsyncData(
      state.requireValue.copyWith(isSubmitting: true, actionFailure: null),
    );

    try {
      final ownerUid = _currentUserUid();
      await ref
          .read(medicationRepositoryProvider)
          .updateMedication(
            ownerUid: ownerUid,
            medicationId: medicationId,
            input: input,
          );
      if (!ref.mounted) return true;
      ref.invalidate(medicationListProvider);
      state = AsyncData(
        state.requireValue.copyWith(
          isEditing: false,
          isSubmitting: false,
          actionFailure: null,
        ),
      );
      return true;
    } on Object catch (error, stackTrace) {
      if (!ref.mounted) return false;
      state = AsyncData(
        state.requireValue.copyWith(
          isSubmitting: false,
          actionFailure: _mapFailure(
            error,
            stackTrace,
            ref.read(appLoggerProvider('medications.controller')),
          ),
        ),
      );
      return false;
    }
  }

  Future<bool> archive() async {
    if (!state.hasValue) return false;
    state = AsyncData(
      state.requireValue.copyWith(isSubmitting: true, actionFailure: null),
    );

    try {
      final ownerUid = _currentUserUid();
      await ref
          .read(medicationRepositoryProvider)
          .archiveMedication(ownerUid: ownerUid, medicationId: medicationId);
      if (!ref.mounted) return true;
      ref.invalidate(medicationListProvider);
      state = AsyncData(state.requireValue.copyWith(isSubmitting: false));
      return true;
    } on Object catch (error, stackTrace) {
      if (!ref.mounted) return false;
      state = AsyncData(
        state.requireValue.copyWith(
          isSubmitting: false,
          actionFailure: _mapFailure(
            error,
            stackTrace,
            ref.read(appLoggerProvider('medications.controller')),
          ),
        ),
      );
      return false;
    }
  }

  Future<bool> permanentlyDelete() async {
    if (!state.hasValue) return false;
    state = AsyncData(
      state.requireValue.copyWith(isSubmitting: true, actionFailure: null),
    );

    try {
      final ownerUid = _currentUserUid();
      await ref
          .read(medicationRepositoryProvider)
          .permanentlyDeleteMedication(
            ownerUid: ownerUid,
            medicationId: medicationId,
          );
      if (!ref.mounted) return true;
      ref.invalidate(medicationListProvider);
      state = AsyncData(
        state.requireValue.copyWith(
          isSubmitting: false,
          didCompleteDelete: true,
        ),
      );
      return true;
    } on Object catch (error, stackTrace) {
      if (!ref.mounted) return false;
      state = AsyncData(
        state.requireValue.copyWith(
          isSubmitting: false,
          actionFailure: _mapFailure(
            error,
            stackTrace,
            ref.read(appLoggerProvider('medications.controller')),
          ),
        ),
      );
      return false;
    }
  }

  String _currentUserUid() {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) throw MedicationFailures.missingSession();
    return user.uid;
  }
}

BaseFailure _mapFailure(Object error, StackTrace stackTrace, AppLogger logger) {
  if (error is BaseFailure) return error;
  return AppFailureMapper.map(error, stackTrace: stackTrace, logger: logger);
}
