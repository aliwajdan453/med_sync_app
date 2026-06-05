import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('dose tracking feature keeps screens in views layer', () {
    expect(
      File(
        'lib/features/dose_tracking/views/missed_dose_screen.dart',
      ).existsSync(),
      isTrue,
    );
    expect(
      File(
        'lib/features/dose_tracking/presentation/missed_dose_screen.dart',
      ).existsSync(),
      isFalse,
    );
  });
}
