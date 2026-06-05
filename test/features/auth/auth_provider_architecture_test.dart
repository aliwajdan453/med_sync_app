import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('auth dependency providers are generated app-lifetime providers', () {
    final source = File(
      'lib/features/auth/state/auth_providers.dart',
    ).readAsStringSync();

    expect(source, contains('@Riverpod(keepAlive: true)\nFirebaseAuth'));
    expect(source, contains('@Riverpod(keepAlive: true)\nFirebaseFirestore'));
    expect(source, contains('@Riverpod(keepAlive: true)\nAuthRepository'));
    expect(source, contains('@Riverpod(keepAlive: true)\nProfileRepository'));
  });

  test('auth controller keeps feedback state writes inside mounted guards', () {
    final source = File(
      'lib/features/auth/state/auth_controller.dart',
    ).readAsStringSync();

    expect(
      source,
      isNot(contains('state = state.copyWith(didSendPasswordReset: true);')),
    );
    expect(
      source,
      isNot(
        contains('state = state.copyWith(didSendVerificationEmail: true);'),
      ),
    );
  });
}
