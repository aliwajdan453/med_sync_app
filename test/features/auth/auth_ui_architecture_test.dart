import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'auth views do not defer provider cleanup with post-frame callbacks',
    () {
      final viewSources = Directory('lib/features/auth/views')
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'))
          .map((file) => file.readAsStringSync())
          .join('\n');

      expect(viewSources, isNot(contains('addPostFrameCallback')));
    },
  );

  test('profile view uses profileScreenProvider for screen state', () {
    final source = File(
      'lib/features/auth/views/profile_view.dart',
    ).readAsStringSync();

    expect(source, contains('profileScreenProvider'));
    expect(source, isNot(contains('fireImmediately')));
  });

  test('login view delegates screen state to one screen provider', () {
    final viewSource = File(
      'lib/features/auth/views/login_view.dart',
    ).readAsStringSync();
    final providerSource = File(
      'lib/features/auth/state/login_screen_notifier.dart',
    ).readAsStringSync();

    expect(viewSource, contains('class LoginView extends ConsumerWidget'));
    expect(viewSource, contains('loginScreenProvider'));
    expect(viewSource, isNot(contains('authControllerProvider')));
    expect(viewSource, isNot(contains('ConsumerStatefulWidget')));
    expect(RegExp('@riverpod').allMatches(providerSource).length, 1);
  });

  test(
    'login validation uses notifier-owned form key with widget validators',
    () {
      final viewSource = File(
        'lib/features/auth/views/login_view.dart',
      ).readAsStringSync();
      final providerSource = File(
        'lib/features/auth/state/login_screen_notifier.dart',
      ).readAsStringSync();

      expect(providerSource, contains('GlobalKey<FormState>'));
      expect(providerSource, contains('formKey.currentState'));
      expect(viewSource, contains('class _LoginForm extends StatelessWidget'));
      expect(viewSource, contains('Form('));
      expect(viewSource, contains('key: formKey'));
      expect(viewSource, contains('validator:'));
      expect(providerSource, isNot(contains('AuthValidators')));
      expect(providerSource, isNot(contains('validateLogin')));
    },
  );

  test('signup view delegates screen state to one screen provider', () {
    final viewSource = File(
      'lib/features/auth/views/signup_view.dart',
    ).readAsStringSync();
    final providerSource = File(
      'lib/features/auth/state/signup_screen_notifier.dart',
    ).readAsStringSync();

    expect(viewSource, contains('class SignUpView extends ConsumerWidget'));
    expect(viewSource, contains('signupScreenProvider'));
    expect(viewSource, isNot(contains('authControllerProvider')));
    expect(viewSource, isNot(contains('ConsumerStatefulWidget')));
    expect(providerSource, contains('GlobalKey<FormState>'));
    expect(providerSource, contains('formKey.currentState'));
    expect(viewSource, contains('class _SignUpForm extends StatelessWidget'));
    expect(viewSource, contains('Form('));
    expect(viewSource, contains('key: formKey'));
    expect(viewSource, contains('validator:'));
    expect(RegExp('@riverpod').allMatches(providerSource).length, 1);
  });

  test('forgot password view delegates form resources to screen provider', () {
    final viewSource = File(
      'lib/features/auth/views/forgot_password_view.dart',
    ).readAsStringSync();
    final providerSource = File(
      'lib/features/auth/state/forgot_password_screen_notifier.dart',
    ).readAsStringSync();

    expect(
      viewSource,
      contains('class ForgotPasswordView extends ConsumerWidget'),
    );
    expect(viewSource, contains('forgotPasswordScreenProvider'));
    expect(viewSource, isNot(contains('authControllerProvider')));
    expect(viewSource, isNot(contains('ConsumerStatefulWidget')));
    expect(providerSource, contains('GlobalKey<FormState>'));
    expect(providerSource, contains('formKey.currentState'));
    expect(
      viewSource,
      contains('class _ForgotPasswordForm extends StatelessWidget'),
    );
    expect(viewSource, contains('Form('));
    expect(viewSource, contains('key: formKey'));
    expect(viewSource, contains('validator:'));
    expect(RegExp('@riverpod').allMatches(providerSource).length, 1);
  });

  test('change password view delegates form resources to screen provider', () {
    final viewSource = File(
      'lib/features/auth/views/change_password_view.dart',
    ).readAsStringSync();
    final providerSource = File(
      'lib/features/auth/state/change_password_screen_notifier.dart',
    ).readAsStringSync();

    expect(
      viewSource,
      contains('class ChangePasswordView extends ConsumerWidget'),
    );
    expect(viewSource, contains('changePasswordScreenProvider'));
    expect(viewSource, isNot(contains('authControllerProvider')));
    expect(viewSource, isNot(contains('ConsumerStatefulWidget')));
    expect(providerSource, contains('GlobalKey<FormState>'));
    expect(providerSource, contains('formKey.currentState'));
    expect(
      viewSource,
      contains('class _ChangePasswordForm extends StatelessWidget'),
    );
    expect(viewSource, contains('Form('));
    expect(viewSource, contains('key: formKey'));
    expect(viewSource, contains('validator:'));
    expect(RegExp('@riverpod').allMatches(providerSource).length, 1);
  });

  test('email verification view delegates actions to screen provider', () {
    final viewSource = File(
      'lib/features/auth/views/email_verification_view.dart',
    ).readAsStringSync();
    final providerSource = File(
      'lib/features/auth/state/email_verification_screen_notifier.dart',
    ).readAsStringSync();

    expect(
      viewSource,
      contains('class EmailVerificationView extends ConsumerWidget'),
    );
    expect(viewSource, contains('emailVerificationScreenProvider'));
    expect(viewSource, isNot(contains('authControllerProvider')));
    expect(viewSource, isNot(contains('ConsumerStatefulWidget')));
    expect(providerSource, contains('Future<bool> refreshVerification()'));
    expect(providerSource, contains('Future<bool> resendVerificationEmail()'));
    expect(providerSource, contains('Future<bool> signOut()'));
    expect(RegExp('@riverpod').allMatches(providerSource).length, 1);
  });

  test('auth form views watch state and read notifier resources', () {
    final loginSource = File(
      'lib/features/auth/views/login_view.dart',
    ).readAsStringSync();
    final signupSource = File(
      'lib/features/auth/views/signup_view.dart',
    ).readAsStringSync();
    final forgotPasswordSource = File(
      'lib/features/auth/views/forgot_password_view.dart',
    ).readAsStringSync();
    final changePasswordSource = File(
      'lib/features/auth/views/change_password_view.dart',
    ).readAsStringSync();
    final emailVerificationSource = File(
      'lib/features/auth/views/email_verification_view.dart',
    ).readAsStringSync();

    expect(loginSource, contains('ref.watch(loginScreenProvider)'));
    expect(loginSource, contains('ref.read(loginScreenProvider.notifier)'));
    expect(
      loginSource,
      isNot(contains('ref.watch(loginScreenProvider.notifier)')),
    );

    expect(signupSource, contains('ref.watch(signupScreenProvider)'));
    expect(signupSource, contains('ref.read(signupScreenProvider.notifier)'));
    expect(
      signupSource,
      isNot(contains('ref.watch(signupScreenProvider.notifier)')),
    );

    expect(
      forgotPasswordSource,
      contains('ref.watch(forgotPasswordScreenProvider)'),
    );
    expect(
      forgotPasswordSource,
      contains('ref.read(forgotPasswordScreenProvider.notifier)'),
    );
    expect(
      forgotPasswordSource,
      isNot(contains('ref.watch(forgotPasswordScreenProvider.notifier)')),
    );

    expect(
      changePasswordSource,
      contains('ref.watch(changePasswordScreenProvider)'),
    );
    expect(
      changePasswordSource,
      contains('ref.read(changePasswordScreenProvider.notifier)'),
    );
    expect(
      changePasswordSource,
      isNot(contains('ref.watch(changePasswordScreenProvider.notifier)')),
    );

    expect(
      emailVerificationSource,
      contains('ref.watch(emailVerificationScreenProvider)'),
    );
    expect(
      emailVerificationSource,
      contains('ref.read(emailVerificationScreenProvider.notifier)'),
    );
    expect(
      emailVerificationSource,
      isNot(contains('ref.watch(emailVerificationScreenProvider.notifier)')),
    );
  });

  test('splash remains a stateless loading screen without form provider', () {
    final source = File(
      'lib/features/auth/views/splash_view.dart',
    ).readAsStringSync();

    expect(source, contains('class SplashView extends StatelessWidget'));
    expect(source, isNot(contains('Consumer')));
    expect(source, isNot(contains('Provider')));
    expect(source, isNot(contains('TextEditingController')));
    expect(source, isNot(contains('FocusNode')));
  });
}
