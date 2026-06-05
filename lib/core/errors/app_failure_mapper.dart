import 'package:firebase_auth/firebase_auth.dart';
import 'package:med_sync/core/base_failure.dart';
import 'package:med_sync/core/logging/app_logger.dart';

abstract final class AppFailureMapper {
  static BaseFailure map(
    Object error, {
    StackTrace? stackTrace,
    AppLogger? logger,
  }) {
    if (error is BaseFailure) return error;

    final failure = switch (error) {
      FirebaseAuthException() => _mapFirebaseAuthException(error),
      FirebaseException() => _mapFirebaseException(error),
      _ => _unknownFailure(error, stackTrace),
    };

    if (_shouldLog(error)) {
      logger?.error(
        'Unhandled exception mapped to BaseFailure.',
        error: error,
        stackTrace: stackTrace,
        context: <String, Object?>{
          'failureTitle': failure.title,
          'diagnosticCode': failure.diagnosticCode,
        },
      );
    }

    return failure;
  }

  static bool _shouldLog(Object error) =>
      error is! FirebaseException && error is! BaseFailure;

  static BaseFailure _mapFirebaseAuthException(FirebaseAuthException error) {
    final diagnosticMessage = error.message ?? error.toString();

    return switch (error.code) {
      'invalid-email' => BaseFailure(
        title: 'Check email',
        description: 'Enter a valid email address.',
        fieldErrors: const {'email': 'Enter a valid email address.'},
        diagnosticCode: error.code,
        diagnosticMessage: diagnosticMessage,
        error: error,
      ),
      'user-disabled' => _firebaseFailure(
        error,
        title: 'Sign in failed',
        description: 'This account is disabled.',
      ),
      'user-not-found' => BaseFailure(
        title: 'Sign in failed',
        description: 'No account was found for that email.',
        fieldErrors: const {'email': 'No account was found for this email.'},
        diagnosticCode: error.code,
        diagnosticMessage: diagnosticMessage,
        error: error,
      ),
      'wrong-password' || 'invalid-credential' => BaseFailure(
        title: 'Sign in failed',
        description: 'The email or password is incorrect.',
        fieldErrors: const {'password': 'Check your password.'},
        diagnosticCode: error.code,
        diagnosticMessage: diagnosticMessage,
        error: error,
      ),
      'email-already-in-use' => BaseFailure(
        title: 'Email already used',
        description: 'An account already exists for this email.',
        fieldErrors: const {
          'email': 'An account already exists for this email.',
        },
        diagnosticCode: error.code,
        diagnosticMessage: diagnosticMessage,
        error: error,
      ),
      'weak-password' => BaseFailure(
        title: 'Password too weak',
        description: 'Use at least 6 characters.',
        fieldErrors: const {'password': 'Use at least 6 characters.'},
        diagnosticCode: error.code,
        diagnosticMessage: diagnosticMessage,
        error: error,
      ),
      'operation-not-allowed' => _firebaseFailure(
        error,
        title: 'Sign in unavailable',
        description: 'This sign-in option is not enabled yet.',
      ),
      'too-many-requests' => _firebaseFailure(
        error,
        title: 'Too many attempts',
        description: 'Too many attempts. Wait a bit and try again.',
      ),
      'network-request-failed' => _firebaseFailure(
        error,
        title: 'Network unavailable',
        description: 'Check your connection and try again.',
      ),
      'requires-recent-login' => _firebaseFailure(
        error,
        title: 'Confirmation needed',
        description: 'Please confirm it is you before continuing.',
      ),
      'account-exists-with-different-credential' => _firebaseFailure(
        error,
        title: 'Sign in conflict',
        description: 'This email already uses another sign-in method.',
      ),
      _ => _firebaseFailure(
        error,
        title: 'Request failed',
        description: 'We could not complete that request. Try again.',
      ),
    };
  }

  static BaseFailure _mapFirebaseException(FirebaseException error) =>
      switch (error.code) {
        'unavailable' || 'network-request-failed' => _firebaseFailure(
          error,
          title: 'Service unavailable',
          description: 'Check your connection and try again.',
        ),
        'permission-denied' => _firebaseFailure(
          error,
          title: 'Permission denied',
          description: 'You do not have access to this content.',
        ),
        'not-found' => _firebaseFailure(
          error,
          title: 'Content unavailable',
          description: 'This content could not be found.',
        ),
        _ => _firebaseFailure(
          error,
          title: 'Request failed',
          description: 'We could not complete that request. Try again.',
        ),
      };

  static BaseFailure _firebaseFailure(
    FirebaseException error, {
    required String title,
    required String description,
  }) => BaseFailure(
    title: title,
    description: description,
    diagnosticCode: error.code,
    diagnosticMessage: error.message ?? error.toString(),
    error: error,
  );

  static BaseFailure _unknownFailure(Object error, StackTrace? stackTrace) =>
      BaseFailure(
        title: 'Request failed',
        description: 'We could not complete that request. Try again.',
        diagnosticCode: error.runtimeType.toString(),
        diagnosticMessage: error.toString(),
        error: error,
        stackTrace: stackTrace,
      );
}
