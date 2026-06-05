import 'package:flutter_test/flutter_test.dart';
import 'package:med_sync/core/routing/auth_route_decision.dart';
import 'package:med_sync/features/auth/views/auth_landing_view.dart';
import 'package:med_sync/features/auth/views/email_verification_view.dart';
import 'package:med_sync/features/auth/views/login_view.dart';
import 'package:med_sync/features/auth/views/splash_view.dart';
import 'package:med_sync/features/home/views/home_screen.dart';

void main() {
  group('authRedirectPath', () {
    test('keeps loading users on splash', () {
      expect(
        authRedirectPath(
          path: HomeScreen.routePath,
          authState: AuthRouteState.loading,
        ),
        SplashView.routePath,
      );
    });

    test('keeps signed out users in auth routes', () {
      expect(
        authRedirectPath(
          path: LoginView.routePath,
          authState: AuthRouteState.signedOut,
        ),
        isNull,
      );
      expect(
        authRedirectPath(
          path: HomeScreen.routePath,
          authState: AuthRouteState.signedOut,
        ),
        AuthLandingView.routePath,
      );
    });

    test('sends unverified email users to verification', () {
      expect(
        authRedirectPath(
          path: HomeScreen.routePath,
          authState: AuthRouteState.needsEmailVerification,
        ),
        EmailVerificationView.routePath,
      );
    });

    test('sends signed in users away from signed out routes', () {
      expect(
        authRedirectPath(
          path: LoginView.routePath,
          authState: AuthRouteState.signedIn,
        ),
        HomeScreen.routePath,
      );
    });
  });
}
