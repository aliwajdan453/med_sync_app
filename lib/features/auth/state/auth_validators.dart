import 'package:med_sync/core/base_failure.dart';

abstract final class AuthValidators {
  static final _emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  static BaseFailure? validateSignup({
    required String displayName,
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    final errors = <String, String>{};

    if (displayName.trim().isEmpty) {
      errors['displayName'] = 'Enter your name.';
    }
    _validateEmail(email, errors);
    _validatePassword(password, errors);
    _validatePasswordConfirmation(password, confirmPassword, errors);

    return errors.isEmpty ? null : _validationFailure(errors);
  }

  static BaseFailure? validateLogin({
    required String email,
    required String password,
  }) {
    final errors = <String, String>{};

    _addErrorIfPresent(errors, 'email', validateEmailField(email));
    _addErrorIfPresent(
      errors,
      'password',
      validateLoginPasswordField(password),
    );

    return errors.isEmpty ? null : _validationFailure(errors);
  }

  static BaseFailure? validateForgotPassword({required String email}) {
    final errors = <String, String>{};
    _validateEmail(email, errors);
    return errors.isEmpty ? null : _validationFailure(errors);
  }

  static BaseFailure? validateChangePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) {
    final errors = <String, String>{};

    if (currentPassword.isEmpty) {
      errors['currentPassword'] = 'Enter your password.';
    }
    _validatePassword(newPassword, errors, field: 'newPassword');
    _validatePasswordConfirmation(newPassword, confirmPassword, errors);

    return errors.isEmpty ? null : _validationFailure(errors);
  }

  static BaseFailure? validateDeletePassword({required String password}) {
    final errors = <String, String>{};

    if (password.isEmpty) {
      errors['password'] = 'Enter your password.';
    }

    return errors.isEmpty ? null : _validationFailure(errors);
  }

  static BaseFailure _validationFailure(Map<String, String> fieldErrors) =>
      BaseFailure(
        title: 'Check fields',
        description: 'Check the highlighted fields.',
        fieldErrors: fieldErrors,
      );

  static String? validateEmailField(String? email) {
    final value = (email ?? '').trim();
    if (value.isEmpty || !_emailRegex.hasMatch(value)) {
      return 'Enter a valid email address.';
    }

    return null;
  }

  static String? validateDisplayNameField(String? displayName) {
    if ((displayName ?? '').trim().isEmpty) {
      return 'Enter your name.';
    }

    return null;
  }

  static String? validateLoginPasswordField(String? password) {
    if ((password ?? '').isEmpty) {
      return 'Enter your password.';
    }

    return null;
  }

  static String? validateSignupPasswordField(String? password) {
    if ((password ?? '').length < 6) {
      return 'Use at least 6 characters.';
    }

    return null;
  }

  static String? validateConfirmPasswordField({
    required String? password,
    required String? confirmPassword,
  }) {
    if ((password ?? '') != (confirmPassword ?? '')) {
      return 'Passwords do not match.';
    }

    return null;
  }

  static void _addErrorIfPresent(
    Map<String, String> errors,
    String field,
    String? error,
  ) {
    if (error != null) errors[field] = error;
  }

  static void _validateEmail(String email, Map<String, String> errors) {
    _addErrorIfPresent(errors, 'email', validateEmailField(email));
  }

  static void _validatePassword(
    String password,
    Map<String, String> errors, {
    String field = 'password',
  }) {
    if (password.length < 6) {
      errors[field] = 'Use at least 6 characters.';
    }
  }

  static void _validatePasswordConfirmation(
    String password,
    String confirmPassword,
    Map<String, String> errors, {
    String field = 'confirmPassword',
  }) {
    if (password != confirmPassword) {
      errors[field] = 'Passwords do not match.';
    }
  }
}
