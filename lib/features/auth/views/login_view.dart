import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_sync/core/navigation/app_navigator.dart';
import 'package:med_sync/core/widgets/app_error_banner.dart';
import 'package:med_sync/core/widgets/app_primary_button.dart';
import 'package:med_sync/core/widgets/app_text_field.dart';
import 'package:med_sync/features/auth/models/auth_form_state.dart';
import 'package:med_sync/features/auth/state/auth_validators.dart';
import 'package:med_sync/features/auth/state/login_screen_notifier.dart';
import 'package:med_sync/features/auth/views/forgot_password_view.dart';
import 'package:med_sync/features/auth/views/signup_view.dart';
import 'package:med_sync/features/auth/widgets/auth_scaffold.dart';

class LoginView extends ConsumerWidget {
  const LoginView({super.key});

  static const routeName = 'login';
  static const routePath = '/auth/login';

  void _goToForgotPassword(WidgetRef ref) {
    ref.read(loginScreenProvider.notifier).clearFeedback();
    ref.read(appNavigatorProvider).push(ForgotPasswordView.routePath);
  }

  void _goToSignup(WidgetRef ref) {
    ref.read(loginScreenProvider.notifier).clearFeedback();
    ref.read(appNavigatorProvider).push(SignUpView.routePath);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(loginScreenProvider);
    final screen = ref.read(loginScreenProvider.notifier);

    return AuthScaffold(
      title: 'Log in',
      subtitle: 'Use your MedSync account to continue.',
      children: [
        _LoginForm(
          state: state,
          formKey: screen.formKey,
          emailController: screen.emailController,
          passwordController: screen.passwordController,
          emailFocus: screen.emailFocus,
          passwordFocus: screen.passwordFocus,
          onSubmit: screen.submit,
        ),
        TextButton(
          onPressed: () => _goToForgotPassword(ref),
          child: const Text('Forgot password?'),
        ),
        TextButton(
          onPressed: () => _goToSignup(ref),
          child: const Text('Create account'),
        ),
      ],
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.state,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.emailFocus,
    required this.passwordFocus,
    required this.onSubmit,
  });

  final AuthFormState state;
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final FocusNode emailFocus;
  final FocusNode passwordFocus;
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
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            validator: AuthValidators.validateLoginPasswordField,
            onSubmitted: (_) => onSubmit(),
          ),
          const SizedBox(height: 20.0),
          AppPrimaryButton(
            label: 'Log in',
            isLoading: state.isSubmitting,
            onPressed: onSubmit,
          ),
          const SizedBox(height: 12.0),
        ],
      ),
    ),
  );
}
