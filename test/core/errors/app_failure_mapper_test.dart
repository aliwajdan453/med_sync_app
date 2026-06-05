import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:med_sync/core/base_failure.dart';
import 'package:med_sync/core/errors/app_failure_mapper.dart';
import 'package:med_sync/core/logging/app_logger.dart';

void main() {
  group('AppFailureMapper', () {
    test('returns existing base failures unchanged', () {
      const failure = BaseFailure(
        title: 'Already mapped',
        description: 'No extra work.',
      );

      expect(AppFailureMapper.map(failure), same(failure));
    });

    test('maps Firebase auth codes to field failures', () {
      final failure = AppFailureMapper.map(
        FirebaseAuthException(code: 'invalid-email'),
      );

      expect(failure.title, 'Check email');
      expect(failure.description, 'Enter a valid email address.');
      expect(failure.fieldErrors['email'], 'Enter a valid email address.');
      expect(failure.diagnosticCode, 'invalid-email');
    });

    test('maps Firebase reauth codes to confirmation failures', () {
      final failure = AppFailureMapper.map(
        FirebaseAuthException(code: 'requires-recent-login'),
      );

      expect(failure.title, 'Confirmation needed');
      expect(failure.description, contains('confirm it is you'));
    });

    test('maps generic Firebase exceptions without auth assumptions', () {
      final failure = AppFailureMapper.map(
        FirebaseException(plugin: 'cloud_firestore', code: 'unavailable'),
      );

      expect(failure.title, 'Service unavailable');
      expect(failure.description, 'Check your connection and try again.');
      expect(failure.diagnosticCode, 'unavailable');
    });

    test('logs unknown exceptions and returns one unknown failure shape', () {
      final logger = _FakeLogger();
      final error = StateError('bad state');
      final stackTrace = StackTrace.current;

      final failure = AppFailureMapper.map(
        error,
        stackTrace: stackTrace,
        logger: logger,
      );

      expect(failure.title, 'Request failed');
      expect(
        failure.description,
        'We could not complete that request. Try again.',
      );
      expect(failure.diagnosticCode, 'StateError');
      expect(failure.error, same(error));
      expect(failure.stackTrace, stackTrace);
      expect(logger.errors.single.error, same(error));
      expect(logger.errors.single.stackTrace, stackTrace);
    });

    test('exposes only one public mapper method', () {
      final source = File(
        'lib/core/errors/app_failure_mapper.dart',
      ).readAsStringSync();

      expect(source, contains('static BaseFailure map('));
      expect(source, isNot(contains('AuthFailureKind')));
      expect(source, isNot(contains('static BaseFailure validation')));
      expect(source, isNot(contains('static BaseFailure provider')));
    });
  });
}

class _FakeLogger implements AppLogger {
  final errors = <_LoggedError>[];

  @override
  void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> context = const {},
  }) {
    errors.add(
      _LoggedError(
        message: message,
        error: error,
        stackTrace: stackTrace,
        context: context,
      ),
    );
  }

  @override
  void info(String message, {Map<String, Object?> context = const {}}) {}

  @override
  void warning(String message, {Map<String, Object?> context = const {}}) {}
}

class _LoggedError {
  const _LoggedError({
    required this.message,
    required this.error,
    required this.stackTrace,
    required this.context,
  });

  final String message;
  final Object? error;
  final StackTrace? stackTrace;
  final Map<String, Object?> context;
}
