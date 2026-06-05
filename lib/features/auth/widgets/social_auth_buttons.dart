import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_sync/core/widgets/app_primary_button.dart';
import 'package:med_sync/features/auth/state/auth_controller.dart';
import 'package:med_sync/features/auth/state/auth_providers.dart';

class SocialAuthButtons extends ConsumerWidget {
  const SocialAuthButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authControllerProvider);
    final appleAvailable = ref.watch(appleSignInAvailableProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppPrimaryButton(
          label: 'Continue with Google',
          icon: Icons.g_mobiledata,
          isLoading: state.isSubmitting,
          onPressed: () =>
              ref.read(authControllerProvider.notifier).signInWithGoogle(),
        ),
        appleAvailable.when(
          data: (isAvailable) {
            if (!isAvailable) return const SizedBox.shrink();
            return Column(
              children: [
                const SizedBox(height: 12.0),
                AppPrimaryButton(
                  label: 'Continue with Apple',
                  icon: Icons.apple,
                  isLoading: state.isSubmitting,
                  onPressed: () => ref
                      .read(authControllerProvider.notifier)
                      .signInWithApple(),
                ),
              ],
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}
