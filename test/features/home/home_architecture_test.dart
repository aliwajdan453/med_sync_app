import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('home feature keeps screens in views layer', () {
    expect(
      File('lib/features/home/views/home_screen.dart').existsSync(),
      isTrue,
    );
    expect(
      File('lib/features/home/presentation/home_screen.dart').existsSync(),
      isFalse,
    );
  });
}
