import 'package:flutter/material.dart';
import 'package:med_sync/features/auth/models/auth_form_state.dart';
import 'package:med_sync/features/auth/state/auth_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part '../../../generated/features/auth/state/change_password_screen_notifier.g.dart';

@riverpod
class ChangePasswordScreen extends _$ChangePasswordScreen {
  GlobalKey<FormState>? _formKey;
  TextEditingController? _currentController;
  TextEditingController? _newController;
  TextEditingController? _confirmController;
  FocusNode? _currentFocus;
  FocusNode? _newFocus;
  FocusNode? _confirmFocus;

  GlobalKey<FormState> get formKey => _formKey!;
  TextEditingController get currentController => _currentController!;
  TextEditingController get newController => _newController!;
  TextEditingController get confirmController => _confirmController!;
  FocusNode get currentFocus => _currentFocus!;
  FocusNode get newFocus => _newFocus!;
  FocusNode get confirmFocus => _confirmFocus!;

  @override
  AuthFormState build() {
    _formKey ??= GlobalKey<FormState>();
    _currentController ??= TextEditingController();
    _newController ??= TextEditingController();
    _confirmController ??= TextEditingController();
    _currentFocus ??= FocusNode();
    _newFocus ??= FocusNode();
    _confirmFocus ??= FocusNode();

    ref
      ..listen(authControllerProvider, (_, next) {
        state = next;
      })
      ..onDispose(() {
        _formKey = null;
        _currentController?.dispose();
        _newController?.dispose();
        _confirmController?.dispose();
        _currentFocus?.dispose();
        _newFocus?.dispose();
        _confirmFocus?.dispose();
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
        .changePassword(
          ChangePasswordFormInput(
            currentPassword: currentController.text,
            newPassword: newController.text,
            confirmPassword: confirmController.text,
          ),
        );
  }

  void clearFailure() {
    state = state.copyWith(failure: null);
    ref.read(authControllerProvider.notifier).clearFailure();
  }
}
