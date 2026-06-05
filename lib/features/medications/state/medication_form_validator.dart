import 'package:med_sync/features/medications/models/medication.dart';

class MedicationValidationResult {
  const MedicationValidationResult(this.fieldErrors);

  final Map<String, String> fieldErrors;

  bool get isValid => fieldErrors.isEmpty;
}

abstract final class MedicationFormValidator {
  static MedicationValidationResult validate(MedicationFormInput input) {
    final errors = <String, String>{};
    final name = input.name.trim();
    final doseUnit = _resolvedDoseUnit(input);
    final instructions = input.instructions.trim();

    if (name.isEmpty) {
      errors['name'] = 'Enter a medication name.';
    }
    if (input.doseAmount == null || input.doseAmount! <= 0) {
      errors['doseAmount'] = 'Enter a dose amount.';
    }
    if (doseUnit.isEmpty) {
      errors['doseUnit'] = 'Choose a dose unit.';
    }
    if (instructions.isEmpty) {
      errors['instructions'] = 'Enter routine instructions.';
    }

    _validateSchedule(input, errors);
    _validateRefill(input.refillInfo, errors);

    return MedicationValidationResult(Map.unmodifiable(errors));
  }

  static String resolvedDoseUnit(MedicationFormInput input) =>
      _resolvedDoseUnit(input);

  static void _validateSchedule(
    MedicationFormInput input,
    Map<String, String> errors,
  ) {
    final schedule = input.schedule;
    switch (input.routineType) {
      case MedicationRoutineType.asNeeded:
        if (schedule != null) {
          errors['schedule'] = 'As-needed routines cannot have a schedule.';
        }
      case MedicationRoutineType.scheduled:
        if (schedule == null || schedule.times.isEmpty) {
          errors['schedule'] = 'Add at least one scheduled time.';
          return;
        }
        if (schedule.pattern == MedicationSchedulePattern.weekdays &&
            schedule.weekdays.isEmpty) {
          errors['weekdays'] = 'Choose at least one day.';
        }
    }
  }

  static void _validateRefill(
    RefillInfo? refillInfo,
    Map<String, String> errors,
  ) {
    if (refillInfo == null) {
      return;
    }
    if (refillInfo.currentQuantity <= 0) {
      errors['currentQuantity'] = 'Enter a quantity greater than zero.';
    }
    if (refillInfo.doseQuantity <= 0) {
      errors['doseQuantity'] = 'Enter a dose quantity greater than zero.';
    }
    if (refillInfo.reminderThreshold <= 0) {
      errors['reminderThreshold'] = 'Enter a threshold greater than zero.';
    }
  }

  static String _resolvedDoseUnit(MedicationFormInput input) {
    if (input.doseUnit == 'custom') {
      return input.customDoseUnit.trim();
    }
    return input.doseUnit.trim();
  }
}
