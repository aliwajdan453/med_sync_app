import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('progress feature keeps screens in views layer', () {
    expect(
      File('lib/features/progress/views/progress_screen.dart').existsSync(),
      isTrue,
    );
    expect(
      File(
        'lib/features/progress/presentation/progress_screen.dart',
      ).existsSync(),
      isFalse,
    );
  });
}
