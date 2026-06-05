import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('app session provider is generated with riverpod_annotation', () {
    final source = File('lib/app/app_session.dart').readAsStringSync();

    expect(source, contains('@riverpod'));
    expect(source, isNot(contains('Provider<VoidCallback>')));
  });
}
