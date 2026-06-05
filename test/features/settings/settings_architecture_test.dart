import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('settings feature keeps screens in views layer', () {
    expect(
      File('lib/features/settings/views/settings_screen.dart').existsSync(),
      isTrue,
    );
    expect(
      File(
        'lib/features/settings/presentation/settings_screen.dart',
      ).existsSync(),
      isFalse,
    );
  });
}
