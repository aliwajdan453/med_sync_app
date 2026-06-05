import 'package:flutter/material.dart';
import 'package:med_sync/features/auth/models/auth_form_state.dart';
import 'package:med_sync/features/auth/state/auth_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part '../../../generated/features/auth/state/forgot_password_screen_notifier.g.dart';

@riverpod
class ForgotPasswordScreen extends _$ForgotPasswordScreen {
  GlobalKey<FormState>? _formKey;
  TextEditingController? _emailController;
  FocusNode? _emailFocus;

  GlobalKey<FormState> get formKey => _formKey!;
  TextEditingController get emailController => _emailController!;
  FocusNode get emailFocus => _emailFocus!;

  @override
  AuthFormState build() {
    _formKey ??= GlobalKey<FormState>();
    _emailController ??= TextEditingController();
    _emailFocus ??= FocusNode();

    ref
      ..listen(authControllerProvider, (_, next) {
        state = next;
      })
      ..onDispose(() {
        _formKey = null;
        _emailController?.dispose();
        _emailFocus?.dispose();
      });

    return ref.read(authControllerProvider);
  }

  Future<bool> submit() {
    if (!(formKey.currentState?.validate() ?? false)) {
      clearFailure();
      return Future.value(false);
    }

    return ref
        .read(authControllerProvider.notifier)
        .sendPasswordResetEmail(
          PasswordResetFormInput(email: emailController.text),
        );
  }

  void clearFailure() {
    state = state.copyWith(failure: null);
    ref.read(authControllerProvider.notifier).clearFailure();
  }
}
