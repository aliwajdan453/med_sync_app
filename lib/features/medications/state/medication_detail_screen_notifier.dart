import 'package:med_sync/core/base_failure.dart';
import 'package:med_sync/core/errors/app_failure_mapper.dart';
import 'package:med_sync/core/logging/app_logger.dart';
import 'package:med_sync/features/auth/state/auth_providers.dart';
import 'package:med_sync/features/medications/models/medication.dart';
import 'package:med_sync/features/medications/models/medication_detail_state.dart';
import 'package:med_sync/features/medications/models/medication_failure.dart';
import 'package:med_sync/features/medications/state/medication_form_validator.dart';
import 'package:med_sync/features/medications/state/medication_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part '../../../generated/features/medications/state/medication_detail_screen_notifier.g.dart';

@riverpod
class MedicationDetailScreenNotifier
    extends _$MedicationDetailScreenNotifier {
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

    return _submit(() async {
      final ownerUid = _currentUserUid();
      await ref
          .read(medicationRepositoryProvider)
          .updateMedication(
            ownerUid: ownerUid,
            medicationId: medicationId,
            input: input,
          );
      ref.invalidate(medicationListProvider);
    }, onSuccess: (current) => current.copyWith(isEditing: false));
  }

  Future<bool> archive() => _submit(() async {
    final ownerUid = _currentUserUid();
    await ref
        .read(medicationRepositoryProvider)
        .archiveMedication(ownerUid: ownerUid, medicationId: medicationId);
    ref.invalidate(medicationListProvider);
  });

  Future<bool> permanentlyDelete() => _submit(() async {
    final ownerUid = _currentUserUid();
    await ref
        .read(medicationRepositoryProvider)
        .permanentlyDeleteMedication(
          ownerUid: ownerUid,
          medicationId: medicationId,
        );
    ref.invalidate(medicationListProvider);
  }, onSuccess: (current) => current.copyWith(didCompleteDelete: true));

  Future<bool> _submit(
    Future<void> Function() action, {
    MedicationDetailState Function(MedicationDetailState current)? onSuccess,
  }) async {
    if (!state.hasValue) return false;
    state = AsyncData(
      state.requireValue.copyWith(isSubmitting: true, actionFailure: null),
    );

    try {
      await action();
      if (!ref.mounted) return true;
      final current = state.requireValue;
      final successState = onSuccess?.call(current) ?? current;
      state = AsyncData(successState.copyWith(isSubmitting: false));
      return true;
    } on Object catch (error, stackTrace) {
      if (!ref.mounted) return false;
      state = AsyncData(
        state.requireValue.copyWith(
          isSubmitting: false,
          actionFailure: _mapFailure(error, stackTrace),
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

  BaseFailure _mapFailure(Object error, StackTrace stackTrace) {
    if (error is BaseFailure) return error;
    return AppFailureMapper.map(
      error,
      stackTrace: stackTrace,
      logger: ref.read(appLoggerProvider('medications.controller')),
    );
  }
}
