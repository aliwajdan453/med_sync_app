import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:med_sync/core/base_failure.dart';

part '../../../generated/features/medications/models/medication_form_state.freezed.dart';

@freezed
abstract class MedicationFormState with _$MedicationFormState {
  const factory MedicationFormState({
    @Default(false) bool isSubmitting,
    BaseFailure? failure,
    @Default(false) bool didCompleteDelete,
  }) = _MedicationFormState;
}
