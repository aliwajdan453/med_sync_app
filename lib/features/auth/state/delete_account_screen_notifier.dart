import 'package:flutter/material.dart';
import 'package:med_sync/app/app_session.dart';
import 'package:med_sync/core/base_failure.dart';
import 'package:med_sync/core/errors/app_failure_mapper.dart';
import 'package:med_sync/core/logging/app_logger.dart';
import 'package:med_sync/features/auth/models/delete_account_screen_state.dart';
import 'package:med_sync/features/auth/models/user_profile.dart';
import 'package:med_sync/features/auth/state/auth_providers.dart';
import 'package:med_sync/features/auth/state/auth_validators.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part '../../../generated/features/auth/state/delete_account_screen_notifier.g.dart';

@riverpod
class DeleteAccountScreenNotifier extends _$DeleteAccountScreenNotifier {
  GlobalKey<FormState>? _formKey;
  TextEditingController? _passwordController;
  FocusNode? _passwordFocus;

  GlobalKey<FormState> get formKey => _formKey!;
  TextEditingController get passwordController => _passwordController!;
  FocusNode get passwordFocus => _passwordFocus!;

  @override
  Future<DeleteAccountScreenState> build() async {
    _formKey ??= GlobalKey<FormState>();
    _passwordController ??= TextEditingController();
    _passwordFocus ??= FocusNode();

    ref.onDispose(() {
      _passwordController?.dispose();
      _passwordFocus?.dispose();
    });

    final user = await ref.watch(currentUserProvider.future);
    if (user == null) {
      throw const BaseFailure(
        title: 'Session unavailable',
        description: 'You are not signed in.',
        diagnosticCode: 'missing-current-user',
      );
    }
    final repository = ref.read(profileRepositoryProvider);
    final profile =
        await repository.fetchProfile(user.uid) ??
        await repository.upsertFromFirebaseUser(user);
    return DeleteAccountScreenState(profile: profile);
  }

  Future<bool> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) return false;
    return deleteAccount(password: _passwordController!.text);
  }

  Future<bool> deleteAccount({String? password}) async {
    if (!state.hasValue) return false;
    final profile = state.requireValue.profile;

    if (profile.deleteReauthMode == DeleteReauthMode.password) {
      final validation = AuthValidators.validateDeletePassword(
        password: password ?? '',
      );
      if (validation != null) {
        state = AsyncData(
          state.requireValue.copyWith(actionFailure: validation),
        );
        return false;
      }
    }

    state = AsyncData(
      state.requireValue.copyWith(isSubmitting: true, actionFailure: null),
    );

    try {
      final authRepository = ref.read(authRepositoryProvider);
      await authRepository.reauthenticateForDeletion(
        profile: profile,
        password: password,
      );
      if (!ref.mounted) return true;

      await ref.read(profileRepositoryProvider).deleteProfile(profile.uid);
      if (!ref.mounted) return true;

      await authRepository.deleteCurrentUser();
      if (!ref.mounted) return true;

      await authRepository.signOut();
      if (!ref.mounted) return true;

      ref.read(sessionResetterProvider)();
      return true;
    } on Object catch (error, stackTrace) {
      if (!ref.mounted) return false;
      state = AsyncData(
        state.requireValue.copyWith(
          isSubmitting: false,
          actionFailure: AppFailureMapper.map(
            error,
            stackTrace: stackTrace,
            logger: ref.read(appLoggerProvider('auth.delete-account')),
          ),
        ),
      );
      return false;
    }
  }
}
