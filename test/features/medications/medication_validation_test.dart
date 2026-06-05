import 'package:flutter_test/flutter_test.dart';
import 'package:med_sync/features/medications/models/medication.dart';
import 'package:med_sync/features/medications/state/medication_form_validator.dart';

void main() {
  group('MedicationFormValidator', () {
    test('requires structured fields for every medication', () {
      final result = MedicationFormValidator.validate(
        const MedicationFormInput(
          name: '',
          category: MedicationCategory.prescription,
          routineType: MedicationRoutineType.scheduled,
          doseAmount: null,
          doseUnit: '',
          customDoseUnit: '',
          instructions: '',
          schedule: null,
          refillInfo: null,
        ),
      );

      expect(result.isValid, isFalse);
      expect(result.fieldErrors['name'], 'Enter a medication name.');
      expect(result.fieldErrors['doseAmount'], 'Enter a dose amount.');
      expect(result.fieldErrors['doseUnit'], 'Choose a dose unit.');
      expect(result.fieldErrors['instructions'], 'Enter routine instructions.');
      expect(
        result.fieldErrors['schedule'],
        'Add at least one scheduled time.',
      );
    });

    test('rejects schedules for as-needed medications', () {
      final result = MedicationFormValidator.validate(
        const MedicationFormInput(
          name: 'Omega-3',
          category: MedicationCategory.supplement,
          routineType: MedicationRoutineType.asNeeded,
          doseAmount: 1,
          doseUnit: 'capsule',
          customDoseUnit: '',
          instructions: 'Take when needed.',
          schedule: MedicationSchedule(
            pattern: MedicationSchedulePattern.daily,
            times: <MedicationTime>[MedicationTime(hour: 8, minute: 0)],
          ),
          refillInfo: null,
        ),
      );

      expect(result.isValid, isFalse);
      expect(
        result.fieldErrors['schedule'],
        'As-needed routines cannot have a schedule.',
      );
    });

    test('requires at least one time for scheduled medication', () {
      final result = MedicationFormValidator.validate(
        const MedicationFormInput(
          name: 'Vitamin D',
          category: MedicationCategory.supplement,
          routineType: MedicationRoutineType.scheduled,
          doseAmount: 1,
          doseUnit: 'tablet',
          customDoseUnit: '',
          instructions: 'Take with breakfast.',
          schedule: MedicationSchedule(
            pattern: MedicationSchedulePattern.daily,
          ),
          refillInfo: null,
        ),
      );

      expect(result.isValid, isFalse);
      expect(
        result.fieldErrors['schedule'],
        'Add at least one scheduled time.',
      );
    });

    test('requires weekdays for weekday schedules', () {
      final result = MedicationFormValidator.validate(
        const MedicationFormInput(
          name: 'Prescription',
          category: MedicationCategory.prescription,
          routineType: MedicationRoutineType.scheduled,
          doseAmount: 20,
          doseUnit: 'mg',
          customDoseUnit: '',
          instructions: 'Follow the label.',
          schedule: MedicationSchedule(
            pattern: MedicationSchedulePattern.weekdays,
            times: <MedicationTime>[MedicationTime(hour: 8, minute: 30)],
          ),
          refillInfo: null,
        ),
      );

      expect(result.isValid, isFalse);
      expect(result.fieldErrors['weekdays'], 'Choose at least one day.');
    });

    test('validates refill fields only when refill tracking is enabled', () {
      final disabledResult = MedicationFormValidator.validate(
        const MedicationFormInput(
          name: 'OTC routine',
          category: MedicationCategory.otc,
          routineType: MedicationRoutineType.asNeeded,
          doseAmount: 5,
          doseUnit: 'mL',
          customDoseUnit: '',
          instructions: 'Use when needed.',
          schedule: null,
          refillInfo: null,
        ),
      );

      final enabledResult = MedicationFormValidator.validate(
        const MedicationFormInput(
          name: 'OTC routine',
          category: MedicationCategory.otc,
          routineType: MedicationRoutineType.asNeeded,
          doseAmount: 5,
          doseUnit: 'mL',
          customDoseUnit: '',
          instructions: 'Use when needed.',
          schedule: null,
          refillInfo: RefillInfo(
            currentQuantity: 0,
            doseQuantity: 0,
            reminderThreshold: 0,
          ),
        ),
      );

      expect(disabledResult.isValid, isTrue);
      expect(enabledResult.isValid, isFalse);
      expect(
        enabledResult.fieldErrors['currentQuantity'],
        'Enter a quantity greater than zero.',
      );
      expect(
        enabledResult.fieldErrors['doseQuantity'],
        'Enter a dose quantity greater than zero.',
      );
      expect(
        enabledResult.fieldErrors['reminderThreshold'],
        'Enter a threshold greater than zero.',
      );
    });
  });
}
