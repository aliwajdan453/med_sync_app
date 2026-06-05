import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('medications feature mirrors the auth feature layers', () {
    final expectedFiles = [
      'lib/features/medications/models/medication.dart',
      'lib/features/medications/models/medication_detail_state.dart',
      'lib/features/medications/models/medication_failure.dart',
      'lib/features/medications/models/medication_form_state.dart',
      'lib/features/medications/data/medication_repository.dart',
      'lib/features/medications/data/firestore_medication_repository.dart',
      'lib/features/medications/state/add_medication_controller.dart',
      'lib/features/medications/state/medication_detail_screen_notifier.dart',
      'lib/features/medications/state/medication_form_validator.dart',
      'lib/features/medications/state/medication_providers.dart',
      'lib/features/medications/views/add_medication_screen.dart',
      'lib/features/medications/views/medication_detail_screen.dart',
      'lib/features/medications/views/medications_list_screen.dart',
      'lib/features/medications/widgets/medication_form.dart',
      'lib/features/medications/widgets/medication_dose_fields.dart',
      'lib/features/medications/widgets/medication_refill_fields.dart',
      'lib/features/medications/widgets/medication_schedule_fields.dart',
    ];

    for (final path in expectedFiles) {
      expect(File(path).existsSync(), isTrue, reason: '$path should exist');
    }

    final deprecatedFolders = [
      'lib/features/medications/application',
      'lib/features/medications/domain',
      'lib/features/medications/presentation',
    ];

    for (final path in deprecatedFolders) {
      expect(Directory(path).existsSync(), isFalse, reason: '$path is stale');
    }

    final deprecatedFiles = [
      'lib/features/medications/state/medication_controllers.dart',
    ];

    for (final path in deprecatedFiles) {
      expect(
        File(path).existsSync(),
        isFalse,
        reason: '$path should be deleted',
      );
    }

    final formSource = File(
      'lib/features/medications/widgets/medication_form.dart',
    ).readAsLinesSync();

    expect(formSource.length, lessThanOrEqualTo(280));
  });
}
