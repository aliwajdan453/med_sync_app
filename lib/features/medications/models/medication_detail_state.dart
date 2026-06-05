import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:med_sync/core/base_failure.dart';
import 'package:med_sync/features/medications/models/medication.dart';

part '../../../generated/features/medications/models/medication_detail_state.freezed.dart';

@freezed
abstract class MedicationDetailState with _$MedicationDetailState {
  const factory MedicationDetailState({
    required Medication medication,
    @Default(false) bool isEditing,
    @Default(false) bool isSubmitting,
    @Default(false) bool didCompleteDelete,
    BaseFailure? actionFailure,
  }) = _MedicationDetailState;
}
