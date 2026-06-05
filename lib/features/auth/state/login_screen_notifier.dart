import 'package:flutter/material.dart';
import 'package:med_sync/features/auth/models/auth_form_state.dart';
import 'package:med_sync/features/auth/state/auth_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part '../../../generated/features/auth/state/login_screen_notifier.g.dart';

@riverpod
class LoginScreen extends _$LoginScreen {
  GlobalKey<FormState>? _formKey;
  TextEditingController? _emailController;
  TextEditingController? _passwordController;
  FocusNode? _emailFocus;
  FocusNode? _passwordFocus;

  GlobalKey<FormState> get formKey => _formKey!;
  TextEditingController get emailController => _emailController!;
  TextEditingController get passwordController => _passwordController!;
  FocusNode get emailFocus => _emailFocus!;
  FocusNode get passwordFocus => _passwordFocus!;

  @override
  AuthFormState build() {
    _formKey ??= GlobalKey<FormState>();
    _emailController ??= TextEditingController();
    _passwordController ??= TextEditingController();
    _emailFocus ??= FocusNode();
    _passwordFocus ??= FocusNode();

    ref
      ..listen(authControllerProvider, (_, next) {
        state = next;
      })
      ..onDispose(() {
        _formKey = null;
        _emailController?.dispose();
        _passwordController?.dispose();
        _emailFocus?.dispose();
        _passwordFocus?.dispose();
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
        .signInWithEmail(
          email: emailController.text,
          password: passwordController.text,
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
