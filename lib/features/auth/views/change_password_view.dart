import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_sync/core/widgets/app_error_banner.dart';
import 'package:med_sync/core/widgets/app_primary_button.dart';
import 'package:med_sync/core/widgets/app_text_field.dart';
import 'package:med_sync/features/auth/models/auth_form_state.dart';
import 'package:med_sync/features/auth/state/auth_validators.dart';
import 'package:med_sync/features/auth/state/change_password_screen_notifier.dart';
import 'package:med_sync/features/auth/widgets/auth_scaffold.dart';

class ChangePasswordView extends ConsumerWidget {
  const ChangePasswordView({super.key});

  static const routeName = 'change-password';
  static const routePath = '/profile/change-password';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(changePasswordScreenProvider);
    final screen = ref.read(changePasswordScreenProvider.notifier);

    return AuthScaffold(
      title: 'Change password',
      subtitle: 'Enter your current password before setting a new one.',
      children: [
        _ChangePasswordForm(
          state: state,
          formKey: screen.formKey,
          currentController: screen.currentController,
          newController: screen.newController,
          confirmController: screen.confirmController,
          currentFocus: screen.currentFocus,
          newFocus: screen.newFocus,
          confirmFocus: screen.confirmFocus,
          onSubmit: screen.submit,
        ),
      ],
    );
  }
}

class _ChangePasswordForm extends StatelessWidget {
  const _ChangePasswordForm({
    required this.state,
    required this.formKey,
    required this.currentController,
    required this.newController,
    required this.confirmController,
    required this.currentFocus,
    required this.newFocus,
    required this.confirmFocus,
    required this.onSubmit,
  });

  final AuthFormState state;
  final GlobalKey<FormState> formKey;
  final TextEditingController currentController;
  final TextEditingController newController;
  final TextEditingController confirmController;
  final FocusNode currentFocus;
  final FocusNode newFocus;
  final FocusNode confirmFocus;
  final Future<bool> Function() onSubmit;

  @override
  Widget build(BuildContext context) => AutofillGroup(
    child: Form(
      key: formKey,
      child: Column(
        children: [
          AppErrorBanner(message: state.failure?.description),
          const SizedBox(height: 16.0),
          AppTextField(
            label: 'Current password',
            controller: currentController,
            focusNode: currentFocus,
            obscureText: true,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.password],
            validator: AuthValidators.validateLoginPasswordField,
            onSubmitted: (_) => newFocus.requestFocus(),
          ),
          const SizedBox(height: 14.0),
          AppTextField(
            label: 'New password',
            controller: newController,
            focusNode: newFocus,
            obscureText: true,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.newPassword],
            validator: AuthValidators.validateSignupPasswordField,
            onSubmitted: (_) => confirmFocus.requestFocus(),
          ),
          const SizedBox(height: 14.0),
          AppTextField(
            label: 'Confirm new password',
            controller: confirmController,
            focusNode: confirmFocus,
            obscureText: true,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.newPassword],
            validator: (value) => AuthValidators.validateConfirmPasswordField(
              password: newController.text,
              confirmPassword: value,
            ),
            onSubmitted: (_) => onSubmit(),
          ),
          const SizedBox(height: 20.0),
          AppPrimaryButton(
            label: 'Update password',
            isLoading: state.isSubmitting,
            onPressed: onSubmit,
          ),
        ],
      ),
    ),
  );
}
