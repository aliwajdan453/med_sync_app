import 'package:med_sync/core/errors/app_failure_mapper.dart';
import 'package:med_sync/core/logging/app_logger.dart';
import 'package:med_sync/features/auth/models/auth_form_state.dart';
import 'package:med_sync/features/auth/state/auth_providers.dart';
import 'package:med_sync/features/auth/state/auth_validators.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part '../../../generated/features/auth/state/auth_controller.g.dart';

@riverpod
class AuthController extends _$AuthController {
  @override
  AuthFormState build() => const AuthFormState();

  void clearFailure() {
    state = state.copyWith(failure: null);
  }

  void clearFeedback() {
    state = state.copyWith(
      failure: null,
      didSendPasswordReset: false,
      didSendVerificationEmail: false,
    );
  }

  Future<bool> signUpWithEmail(SignUpFormInput input) async {
    final validation = AuthValidators.validateSignup(
      displayName: input.displayName,
      email: input.email,
      password: input.password,
      confirmPassword: input.confirmPassword,
    );

    if (validation != null) {
      state = state.copyWith(failure: validation);
      return false;
    }

    return _submit(() async {
      final authRepository = ref.read(authRepositoryProvider);

      final user = await authRepository.signUpWithEmail(
        displayName: input.displayName,
        email: input.email,
        password: input.password,
      );

      if (!ref.mounted) return;

      await ref.read(profileRepositoryProvider).upsertFromFirebaseUser(user);

      if (!ref.mounted) return;

      await authRepository.sendEmailVerification();

      if (!ref.mounted) return;

      ref.invalidate(userProfileProvider);
    });
  }

  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final validation = AuthValidators.validateLogin(
      email: email,
      password: password,
    );

    if (validation != null) {
      state = state.copyWith(failure: validation);
      return false;
    }

    return _submit(() async {
      final user = await ref
          .read(authRepositoryProvider)
          .signInWithEmail(email: email, password: password);

      if (!ref.mounted) return;

      await ref.read(profileRepositoryProvider).upsertFromFirebaseUser(user);

      if (!ref.mounted) return;

      ref.invalidate(userProfileProvider);
    });
  }

  Future<bool> signInWithGoogle() => _submit(() async {
    final user = await ref.read(authRepositoryProvider).signInWithGoogle();

    if (!ref.mounted) return;

    await ref.read(profileRepositoryProvider).upsertFromFirebaseUser(user);

    if (!ref.mounted) return;

    ref.invalidate(userProfileProvider);
  });

  Future<bool> signInWithApple() => _submit(() async {
    final user = await ref.read(authRepositoryProvider).signInWithApple();

    if (!ref.mounted) return;

    await ref.read(profileRepositoryProvider).upsertFromFirebaseUser(user);

    if (!ref.mounted) return;

    ref.invalidate(userProfileProvider);
  });

  Future<bool> sendPasswordResetEmail(PasswordResetFormInput input) async {
    final validation = AuthValidators.validateForgotPassword(
      email: input.email,
    );

    if (validation != null) {
      state = state.copyWith(failure: validation);
      return false;
    }

    return _submit(
      () =>
          ref.read(authRepositoryProvider).sendPasswordResetEmail(input.email),
      onSuccess: (current) => current.copyWith(didSendPasswordReset: true),
    );
  }

  Future<bool> resendEmailVerification() => _submit(
    () => ref.read(authRepositoryProvider).sendEmailVerification(),
    onSuccess: (current) => current.copyWith(didSendVerificationEmail: true),
  );

  Future<bool> refreshEmailVerification() => _submit(() async {
    await ref.read(authRepositoryProvider).reloadCurrentUser();

    if (!ref.mounted) return;

    ref.invalidate(userProfileProvider);
  });

  Future<bool> signOut() =>
      _submit(() => ref.read(authRepositoryProvider).signOut());

  Future<bool> changePassword(ChangePasswordFormInput input) async {
    final validation = AuthValidators.validateChangePassword(
      currentPassword: input.currentPassword,
      newPassword: input.newPassword,
      confirmPassword: input.confirmPassword,
    );

    if (validation != null) {
      state = state.copyWith(failure: validation);
      return false;
    }

    return _submit(() async {
      await ref
          .read(authRepositoryProvider)
          .changePassword(
            currentPassword: input.currentPassword,
            newPassword: input.newPassword,
          );
    });
  }

  Future<bool> _submit(
    Future<void> Function() action, {
    AuthFormState Function(AuthFormState current)? onSuccess,
  }) async {
    state = state.copyWith(
      isSubmitting: true,
      failure: null,
      didSendPasswordReset: false,
      didSendVerificationEmail: false,
    );

    try {
      await action();

      if (!ref.mounted) return true;

      final successState = onSuccess?.call(state) ?? state;

      state = successState.copyWith(isSubmitting: false, failure: null);

      return true;
    } on Object catch (error) {
      if (!ref.mounted) return false;

      state = state.copyWith(
        isSubmitting: false,
        failure: AppFailureMapper.map(
          error,
          logger: ref.read(appLoggerProvider('auth.controller')),
        ),
      );

      return false;
    }
  }
}
