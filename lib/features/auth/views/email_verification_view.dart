import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_sync/core/theme/app_colors.dart';
import 'package:med_sync/core/widgets/app_error_banner.dart';
import 'package:med_sync/core/widgets/app_primary_button.dart';
import 'package:med_sync/features/auth/models/auth_form_state.dart';
import 'package:med_sync/features/auth/state/email_verification_screen_notifier.dart';
import 'package:med_sync/features/auth/state/auth_providers.dart';
import 'package:med_sync/features/auth/widgets/auth_scaffold.dart';

class EmailVerificationView extends ConsumerWidget {
  const EmailVerificationView({super.key});

  static const routeName = 'email-verification';
  static const routePath = '/auth/verify-email';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(emailVerificationScreenProvider);
    final screen = ref.read(emailVerificationScreenProvider.notifier);
    final user = ref.watch(currentUserProvider).value;

    return AuthScaffold(
      title: 'Verify your email',
      subtitle:
          'Open the verification email before continuing to your routine.',
      showBackButton: false,
      children: [
        _EmailVerificationActions(
          state: state,
          email: user?.email ?? 'Your email address',
          onRefreshVerification: screen.refreshVerification,
          onResendVerificationEmail: screen.resendVerificationEmail,
          onSignOut: screen.signOut,
        ),
      ],
    );
  }
}

class _EmailVerificationActions extends StatelessWidget {
  const _EmailVerificationActions({
    required this.state,
    required this.email,
    required this.onRefreshVerification,
    required this.onResendVerificationEmail,
    required this.onSignOut,
  });

  final AuthFormState state;
  final String email;
  final Future<bool> Function() onRefreshVerification;
  final Future<bool> Function() onResendVerificationEmail;
  final Future<bool> Function() onSignOut;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      AppErrorBanner(message: state.failure?.description),
      if (state.didSendVerificationEmail) ...[
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.dataTeal.withValues(alpha: 0.14),
            borderRadius: const BorderRadius.all(Radius.circular(18.0)),
          ),
          child: const Padding(
            padding: EdgeInsets.all(14.0),
            child: Text('Verification email sent.'),
          ),
        ),
        const SizedBox(height: 16.0),
      ],
      Text(email, maxLines: 1, overflow: TextOverflow.ellipsis),
      const SizedBox(height: 20.0),
      AppPrimaryButton(
        label: 'I verified my email',
        isLoading: state.isSubmitting,
        onPressed: onRefreshVerification,
      ),
      const SizedBox(height: 12.0),
      TextButton(
        onPressed: state.isSubmitting ? null : onResendVerificationEmail,
        child: const Text('Resend email'),
      ),
      TextButton(
        onPressed: state.isSubmitting ? null : onSignOut,
        child: const Text('Log out'),
      ),
    ],
  );
}
