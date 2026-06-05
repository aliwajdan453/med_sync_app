import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_sync/core/navigation/app_navigator.dart';
import 'package:med_sync/core/widgets/app_error_banner.dart';
import 'package:med_sync/core/widgets/app_primary_button.dart';
import 'package:med_sync/features/auth/state/auth_controller.dart';
import 'package:med_sync/features/auth/views/forgot_password_view.dart';
import 'package:med_sync/features/auth/views/login_view.dart';
import 'package:med_sync/features/auth/views/signup_view.dart';
import 'package:med_sync/features/auth/widgets/auth_scaffold.dart';
import 'package:med_sync/features/auth/widgets/social_auth_buttons.dart';

class AuthLandingView extends ConsumerWidget {
  const AuthLandingView({super.key});

  static const routeName = 'auth';
  static const routePath = '/auth';

  void _onNavigateTo(WidgetRef ref, String path) {
    ref.read(authControllerProvider.notifier).clearFeedback();
    ref.read(appNavigatorProvider).push(path);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authControllerProvider);

    return AuthScaffold(
      title: 'Start your routine',
      subtitle:
          'Create an account or sign in to keep your medication routine synced.',
      showBackButton: false,
      children: [
        AppErrorBanner(message: state.failure?.description),
        const SizedBox(height: 16.0),
        AppPrimaryButton(
          label: 'Log in with email',
          icon: Icons.mail_outline,
          onPressed: () => _onNavigateTo(ref, LoginView.routePath),
        ),
        const SizedBox(height: 12.0),
        TextButton(
          onPressed: () => _onNavigateTo(ref, SignUpView.routePath),
          child: const Text('Create account'),
        ),
        const SizedBox(height: 12.0),
        const SocialAuthButtons(),
        const SizedBox(height: 12.0),
        TextButton(
          onPressed: () => _onNavigateTo(ref, ForgotPasswordView.routePath),
          child: const Text('Forgot password?'),
        ),
      ],
    );
  }
}
