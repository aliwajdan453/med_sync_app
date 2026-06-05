import 'package:med_sync/features/auth/views/auth_landing_view.dart';
import 'package:med_sync/features/auth/views/email_verification_view.dart';
import 'package:med_sync/features/auth/views/forgot_password_view.dart';
import 'package:med_sync/features/auth/views/login_view.dart';
import 'package:med_sync/features/auth/views/signup_view.dart';
import 'package:med_sync/features/auth/views/splash_view.dart';
import 'package:med_sync/features/home/views/home_screen.dart';

enum AuthRouteState { loading, signedOut, needsEmailVerification, signedIn }

const signedOutRoutePaths = {
  AuthLandingView.routePath,
  LoginView.routePath,
  SignUpView.routePath,
  ForgotPasswordView.routePath,
};

String? authRedirectPath({
  required String path,
  required AuthRouteState authState,
}) {
  final isSplash = path == SplashView.routePath;
  final isSignedOutPath = signedOutRoutePaths.contains(path);
  final isVerificationPath = path == EmailVerificationView.routePath;

  switch (authState) {
    case AuthRouteState.loading:
      return isSplash ? null : SplashView.routePath;
    case AuthRouteState.signedOut:
      return isSignedOutPath ? null : AuthLandingView.routePath;
    case AuthRouteState.needsEmailVerification:
      return isVerificationPath ? null : EmailVerificationView.routePath;
    case AuthRouteState.signedIn:
      if (isSplash || isSignedOutPath || isVerificationPath) {
        return HomeScreen.routePath;
      }
      return null;
  }
}
