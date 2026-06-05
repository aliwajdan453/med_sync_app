import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:med_sync/core/base_failure.dart';

part '../../../generated/features/auth/models/auth_form_state.freezed.dart';

@freezed
abstract class AuthFormState with _$AuthFormState {
  const factory AuthFormState({
    @Default(false) bool isSubmitting,
    @Default(false) bool didSendPasswordReset,
    @Default(false) bool didSendVerificationEmail,
    BaseFailure? failure,
  }) = _AuthFormState;
}

@freezed
abstract class SignUpFormInput with _$SignUpFormInput {
  const factory SignUpFormInput({
    required String displayName,
    required String email,
    required String password,
    required String confirmPassword,
  }) = _SignUpFormInput;
}

@freezed
abstract class PasswordResetFormInput with _$PasswordResetFormInput {
  const factory PasswordResetFormInput({required String email}) =
      _PasswordResetFormInput;
}

@freezed
abstract class ChangePasswordFormInput with _$ChangePasswordFormInput {
  const factory ChangePasswordFormInput({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) = _ChangePasswordFormInput;
}
