import 'package:flutter/material.dart';
import 'package:med_sync/features/auth/models/auth_form_state.dart';
import 'package:med_sync/features/auth/state/auth_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part '../../../generated/features/auth/state/signup_screen_notifier.g.dart';

@riverpod
class SignupScreen extends _$SignupScreen {
  GlobalKey<FormState>? _formKey;
  TextEditingController? _nameController;
  TextEditingController? _emailController;
  TextEditingController? _passwordController;
  TextEditingController? _confirmPasswordController;
  FocusNode? _nameFocus;
  FocusNode? _emailFocus;
  FocusNode? _passwordFocus;
  FocusNode? _confirmPasswordFocus;

  GlobalKey<FormState> get formKey => _formKey!;
  TextEditingController get nameController => _nameController!;
  TextEditingController get emailController => _emailController!;
  TextEditingController get passwordController => _passwordController!;
  TextEditingController get confirmPasswordController =>
      _confirmPasswordController!;
  FocusNode get nameFocus => _nameFocus!;
  FocusNode get emailFocus => _emailFocus!;
  FocusNode get passwordFocus => _passwordFocus!;
  FocusNode get confirmPasswordFocus => _confirmPasswordFocus!;

  @override
  AuthFormState build() {
    _formKey ??= GlobalKey<FormState>();
    _nameController ??= TextEditingController();
    _emailController ??= TextEditingController();
    _passwordController ??= TextEditingController();
    _confirmPasswordController ??= TextEditingController();
    _nameFocus ??= FocusNode();
    _emailFocus ??= FocusNode();
    _passwordFocus ??= FocusNode();
    _confirmPasswordFocus ??= FocusNode();

    ref
      ..listen(authControllerProvider, (_, next) {
        state = next;
      })
      ..onDispose(() {
        _formKey = null;
        _nameController?.dispose();
        _emailController?.dispose();
        _passwordController?.dispose();
        _confirmPasswordController?.dispose();
        _nameFocus?.dispose();
        _emailFocus?.dispose();
        _passwordFocus?.dispose();
        _confirmPasswordFocus?.dispose();
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
        .signUpWithEmail(
          SignUpFormInput(
            displayName: nameController.text,
            email: emailController.text,
            password: passwordController.text,
            confirmPassword: confirmPasswordController.text,
          ),
        );
  }

  void clearFeedback() {
    state = state.copyWith(
      failure: null,
      didSendPasswordReset: false,
      didSendVerificationEmail: false,
    );

    ref.read(authControllerProvider.notifier).clearFeedback();
  }

  void clearFailure() {
    state = state.copyWith(failure: null);
    ref.read(authControllerProvider.notifier).clearFailure();
  }
}
