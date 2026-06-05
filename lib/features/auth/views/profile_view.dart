import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_sync/core/design_system/base_app_bar.dart';
import 'package:med_sync/core/design_system/base_scaffold.dart';
import 'package:med_sync/core/navigation/app_navigator.dart';
import 'package:med_sync/core/theme/app_colors.dart';
import 'package:med_sync/core/widgets/app_async_value_widget.dart';
import 'package:med_sync/core/widgets/app_error_banner.dart';
import 'package:med_sync/core/widgets/app_primary_button.dart';
import 'package:med_sync/core/widgets/app_text_field.dart';
import 'package:med_sync/features/auth/models/user_profile.dart';
import 'package:med_sync/features/auth/state/auth_validators.dart';
import 'package:med_sync/features/auth/state/profile_screen_notifier.dart';
import 'package:med_sync/features/auth/views/change_password_view.dart';
import 'package:med_sync/features/auth/views/delete_account_view.dart';

class ProfileView extends ConsumerWidget {
  const ProfileView({super.key});

  static const routeName = 'profile';
  static const routePath = '/profile';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(profileScreenProvider);
    final screen = ref.read(profileScreenProvider.notifier);

    return BaseScaffold(
      appBar: const BaseAppBar(title: 'Profile'),
      child: AppAsyncValueWidget(
        value: asyncState,
        data: (context, screenState) => _ProfileBody(
          profile: screenState.profile,
          formKey: screen.formKey,
          nameController: screen.nameController,
          nameFocus: screen.nameFocus,
          errorMessage: screenState.actionFailure?.description,
          isSubmitting: screenState.isSubmitting,
          onSave: screen.submit,
          onChangePassword: screenState.profile.hasPasswordProvider
              ? () => ref
                    .read(appNavigatorProvider)
                    .push(ChangePasswordView.routePath)
              : null,
          onDeleteAccount: () =>
              ref.read(appNavigatorProvider).push(DeleteAccountView.routePath),
          onLogout: () => ref.read(profileScreenProvider.notifier).signOut(),
        ),
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({
    required this.profile,
    required this.formKey,
    required this.nameController,
    required this.nameFocus,
    required this.onSave,
    required this.onChangePassword,
    required this.onDeleteAccount,
    required this.onLogout,
    required this.isSubmitting,
    this.errorMessage,
  });

  final UserProfile profile;
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final FocusNode nameFocus;
  final Future<bool> Function() onSave;
  final VoidCallback? onChangePassword;
  final VoidCallback onDeleteAccount;
  final Future<bool> Function() onLogout;
  final bool isSubmitting;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) => Form(
    key: formKey,
    child: ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        AppErrorBanner(message: errorMessage),
        const SizedBox(height: 16.0),
        AppTextField(
          label: 'Name',
          controller: nameController,
          focusNode: nameFocus,
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.name],
          validator: AuthValidators.validateDisplayNameField,
          onSubmitted: (_) => onSave(),
        ),
        const SizedBox(height: 12.0),
        AppPrimaryButton(
          label: 'Save name',
          isLoading: isSubmitting,
          onPressed: onSave,
        ),
        const SizedBox(height: 24.0),
        _InfoRow(label: 'Email', value: profile.email),
        const SizedBox(height: 8.0),
        _InfoRow(
          label: 'Email verified',
          value: profile.emailVerified ? 'Yes' : 'No',
        ),
        const SizedBox(height: 8.0),
        _InfoRow(label: 'Sign-in methods', value: profile.providerIds.join(', ')),
        const SizedBox(height: 24.0),
        if (onChangePassword != null) ...[
          TextButton.icon(
            onPressed: onChangePassword,
            icon: const Icon(Icons.lock_outline),
            label: const Text('Change password'),
          ),
        ],
        TextButton.icon(
          onPressed: onLogout,
          icon: const Icon(Icons.logout),
          label: const Text('Log out'),
        ),
        const SizedBox(height: 8.0),
        TextButton.icon(
          onPressed: onDeleteAccount,
          icon: const Icon(Icons.delete_outline, color: AppColors.primary),
          label: const Text('Delete account'),
        ),
      ],
    ),
  );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.slateLabel),
        ),
      ),
      Expanded(
        child: Text(
          value,
          textAlign: TextAlign.end,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    ],
  );
}
