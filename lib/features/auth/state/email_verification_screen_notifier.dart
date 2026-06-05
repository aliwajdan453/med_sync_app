import 'package:med_sync/features/auth/models/auth_form_state.dart';
import 'package:med_sync/features/auth/state/auth_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part '../../../generated/features/auth/state/email_verification_screen_notifier.g.dart';

@riverpod
class EmailVerificationScreenNotifier
    extends _$EmailVerificationScreenNotifier {
  @override
  AuthFormState build() {
    ref.listen(authControllerProvider, (_, next) {
      state = next;
    });

    return ref.read(authControllerProvider);
  }

  Future<bool> refreshVerification() =>
      ref.read(authControllerProvider.notifier).refreshEmailVerification();

  Future<bool> resendVerificationEmail() =>
      ref.read(authControllerProvider.notifier).resendEmailVerification();

  Future<bool> signOut() => ref.read(authControllerProvider.notifier).signOut();
}
