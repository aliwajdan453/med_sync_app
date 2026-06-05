import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_sync/core/widgets/app_async_value_widget.dart';
import 'package:med_sync/core/widgets/app_error_banner.dart';
import 'package:med_sync/core/widgets/app_primary_button.dart';
import 'package:med_sync/core/widgets/app_text_field.dart';
import 'package:med_sync/features/auth/models/user_profile.dart';
import 'package:med_sync/features/auth/state/auth_validators.dart';
import 'package:med_sync/features/auth/state/delete_account_screen_notifier.dart';
import 'package:med_sync/features/auth/widgets/auth_scaffold.dart';

class DeleteAccountView extends ConsumerWidget {
  const DeleteAccountView({super.key});

  static const routeName = 'delete-account';
  static const routePath = '/profile/delete-account';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(deleteAccountScreenProvider);
    final screen = ref.read(deleteAccountScreenProvider.notifier);

    return AppAsyncValueWidget(
      value: asyncState,
      data: (context, screenState) => _DeleteAccountBody(
        profile: screenState.profile,
        formKey: screen.formKey,
        passwordController: screen.passwordController,
        passwordFocus: screen.passwordFocus,
        errorMessage: screenState.actionFailure?.description,
        isSubmitting: screenState.isSubmitting,
        onSubmit: screen.submit,
      ),
    );
  }
}

class _DeleteAccountBody extends StatelessWidget {
  const _DeleteAccountBody({
    required this.profile,
    required this.formKey,
    required this.passwordController,
    required this.passwordFocus,
    required this.onSubmit,
    required this.isSubmitting,
    this.errorMessage,
  });

  final UserProfile profile;
  final GlobalKey<FormState> formKey;
  final TextEditingController passwordController;
  final FocusNode passwordFocus;
  final Future<bool> Function() onSubmit;
  final bool isSubmitting;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final usesPassword = profile.deleteReauthMode == DeleteReauthMode.password;

    return Form(
      key: formKey,
      child: AuthScaffold(
        title: 'Delete account',
        subtitle:
            'This removes your account and profile from this MVP auth setup.',
        children: [
          AppErrorBanner(message: errorMessage),
          const SizedBox(height: 16.0),
          if (usesPassword) ...[
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
          ] else
            const Text('You will confirm through your sign-in provider.'),
          AppPrimaryButton(
            label: 'Delete account',
            icon: Icons.delete_outline,
            isLoading: isSubmitting,
            onPressed: onSubmit,
          ),
        ],
      ),
    );
  }
}
