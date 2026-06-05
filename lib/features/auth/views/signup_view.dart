import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_sync/core/navigation/app_navigator.dart';
import 'package:med_sync/core/widgets/app_error_banner.dart';
import 'package:med_sync/core/widgets/app_primary_button.dart';
import 'package:med_sync/core/widgets/app_text_field.dart';
import 'package:med_sync/features/auth/models/auth_form_state.dart';
import 'package:med_sync/features/auth/state/auth_validators.dart';
import 'package:med_sync/features/auth/state/signup_screen_notifier.dart';
import 'package:med_sync/features/auth/views/login_view.dart';
import 'package:med_sync/features/auth/widgets/auth_scaffold.dart';

class SignUpView extends ConsumerWidget {
  const SignUpView({super.key});

  static const routeName = 'signup';
  static const routePath = '/auth/signup';

  void _goToLogin(WidgetRef ref) {
    ref.read(signupScreenProvider.notifier).clearFeedback();
    ref.read(appNavigatorProvider).push(LoginView.routePath);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(signupScreenProvider);
    final screen = ref.read(signupScreenProvider.notifier);

    return AuthScaffold(
      title: 'Create account',
      subtitle: 'Set up your account before adding medication routines.',
      children: [
        _SignUpForm(
          state: state,
          formKey: screen.formKey,
          nameController: screen.nameController,
          emailController: screen.emailController,
          passwordController: screen.passwordController,
          confirmPasswordController: screen.confirmPasswordController,
          nameFocus: screen.nameFocus,
          emailFocus: screen.emailFocus,
          passwordFocus: screen.passwordFocus,
          confirmPasswordFocus: screen.confirmPasswordFocus,
          onSubmit: screen.submit,
        ),
        TextButton(
          onPressed: () => _goToLogin(ref),
          child: const Text('Already have an account?'),
        ),
      ],
    );
  }
}

class _SignUpForm extends StatelessWidget {
  const _SignUpForm({
    required this.state,
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.nameFocus,
    required this.emailFocus,
    required this.passwordFocus,
    required this.confirmPasswordFocus,
    required this.onSubmit,
  });

  final AuthFormState state;
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final FocusNode nameFocus;
  final FocusNode emailFocus;
  final FocusNode passwordFocus;
  final FocusNode confirmPasswordFocus;
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
            label: 'Name',
            controller: nameController,
            focusNode: nameFocus,
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.name],
            validator: AuthValidators.validateDisplayNameField,
            onSubmitted: (_) => emailFocus.requestFocus(),
          ),
          const SizedBox(height: 14.0),
          AppTextField(
            label: 'Email',
            controller: emailController,
            focusNode: emailFocus,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            validator: AuthValidators.validateEmailField,
            onSubmitted: (_) => passwordFocus.requestFocus(),
          ),
          const SizedBox(height: 14.0),
          AppTextField(
            label: 'Password',
            controller: passwordController,
            focusNode: passwordFocus,
            obscureText: true,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.newPassword],
            validator: AuthValidators.validateSignupPasswordField,
            onSubmitted: (_) => confirmPasswordFocus.requestFocus(),
          ),
          const SizedBox(height: 14.0),
          AppTextField(
            label: 'Confirm password',
            controller: confirmPasswordController,
            focusNode: confirmPasswordFocus,
            obscureText: true,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.newPassword],
            validator: (value) => AuthValidators.validateConfirmPasswordField(
              password: passwordController.text,
              confirmPassword: value,
            ),
            onSubmitted: (_) => onSubmit(),
          ),
          const SizedBox(height: 20.0),
          AppPrimaryButton(
            label: 'Create account',
            isLoading: state.isSubmitting,
            onPressed: onSubmit,
          ),
          const SizedBox(height: 12.0),
        ],
      ),
    ),
  );
}
