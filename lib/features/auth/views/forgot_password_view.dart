import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_sync/core/theme/app_colors.dart';
import 'package:med_sync/core/widgets/app_error_banner.dart';
import 'package:med_sync/core/widgets/app_primary_button.dart';
import 'package:med_sync/core/widgets/app_text_field.dart';
import 'package:med_sync/features/auth/models/auth_form_state.dart';
import 'package:med_sync/features/auth/state/auth_validators.dart';
import 'package:med_sync/features/auth/state/forgot_password_screen_notifier.dart';
import 'package:med_sync/features/auth/widgets/auth_scaffold.dart';

class ForgotPasswordView extends ConsumerWidget {
  const ForgotPasswordView({super.key});

  static const routeName = 'forgot-password';
  static const routePath = '/auth/forgot-password';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(forgotPasswordScreenProvider);
    final screen = ref.read(forgotPasswordScreenProvider.notifier);

    return AuthScaffold(
      title: 'Reset password',
      subtitle: 'We will send a reset email if this address has an account.',
      children: [
        _ForgotPasswordForm(
          state: state,
          formKey: screen.formKey,
          emailController: screen.emailController,
          emailFocus: screen.emailFocus,
          onSubmit: screen.submit,
        ),
      ],
    );
  }
}

class _ForgotPasswordForm extends StatelessWidget {
  const _ForgotPasswordForm({
    required this.state,
    required this.formKey,
    required this.emailController,
    required this.emailFocus,
    required this.onSubmit,
  });

  final AuthFormState state;
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final FocusNode emailFocus;
  final Future<bool> Function() onSubmit;

  @override
  Widget build(BuildContext context) => Form(
    key: formKey,
    child: Column(
      children: [
        AppErrorBanner(message: state.failure?.description),
        if (state.didSendPasswordReset) ...[
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.dataTeal.withValues(alpha: 0.14),
              borderRadius: const BorderRadius.all(Radius.circular(18.0)),
            ),
            child: const Padding(
              padding: EdgeInsets.all(14.0),
              child: Text('Check your email for a password reset link.'),
            ),
          ),
          const SizedBox(height: 16.0),
        ],
        AppTextField(
          label: 'Email',
          controller: emailController,
          focusNode: emailFocus,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.email],
          validator: AuthValidators.validateEmailField,
          onSubmitted: (_) => onSubmit(),
        ),
        const SizedBox(height: 20.0),
        AppPrimaryButton(
          label: 'Send reset email',
          isLoading: state.isSubmitting,
          onPressed: onSubmit,
        ),
      ],
    ),
  );
}
