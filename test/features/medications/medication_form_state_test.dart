import 'package:med_sync/core/base_failure.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:med_sync/features/medications/models/medication_form_state.dart';

void main() {
  group('MedicationFormState', () {
    test('clears nullable fields by passing null to copyWith', () {
      final state = MedicationFormState(
        failure: BaseFailure(
          title: 'Save failed',
          description: 'Try again.',
          error: StateError('save failed'),
        ),
      );

      final cleared = state.copyWith(failure: null);

      expect(cleared.failure, isNull);
    });
  });
}
