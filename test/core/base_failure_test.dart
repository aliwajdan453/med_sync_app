import 'package:flutter_test/flutter_test.dart';
import 'package:med_sync/core/base_failure.dart';

void main() {
  group('BaseFailure', () {
    test('stores shared user-facing and diagnostic failure data', () {
      final stackTrace = StackTrace.current;
      final failure = BaseFailure(
        title: 'Save failed',
        description: 'Try again.',
        fieldErrors: const {'name': 'Enter a name.'},
        diagnosticCode: 'bad-state',
        diagnosticMessage: 'Bad state',
        error: StateError('bad state'),
        stackTrace: stackTrace,
      );

      expect(failure.title, 'Save failed');
      expect(failure.description, 'Try again.');
      expect(failure.fieldErrors['name'], 'Enter a name.');
      expect(failure.diagnosticCode, 'bad-state');
      expect(failure.diagnosticMessage, 'Bad state');
      expect(failure.error.toString(), contains('bad state'));
      expect(failure.stackTrace, stackTrace);
    });
  });
}
