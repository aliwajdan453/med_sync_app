import 'package:med_sync/core/base_failure.dart';

abstract final class MedicationFailures {
  static BaseFailure validation(Map<String, String> fieldErrors) => BaseFailure(
    title: 'Check fields',
    description: 'Check the highlighted fields.',
    fieldErrors: fieldErrors,
  );

  static BaseFailure missingSession() => const BaseFailure(
    title: 'Session unavailable',
    description: 'We could not find your signed-in session.',
    diagnosticCode: 'missing-current-user',
  );

  static BaseFailure missingMedication() => const BaseFailure(
    title: 'Medication unavailable',
    description: 'This medication could not be found.',
    diagnosticCode: 'missing-medication',
  );
}
