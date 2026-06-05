import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:med_sync/app/app_shell.dart';
import 'package:med_sync/core/routing/auth_route_decision.dart';
import 'package:med_sync/features/auth/state/auth_providers.dart';
import 'package:med_sync/features/auth/views/auth_landing_view.dart';
import 'package:med_sync/features/auth/views/change_password_view.dart';
import 'package:med_sync/features/auth/views/delete_account_view.dart';
import 'package:med_sync/features/auth/views/email_verification_view.dart';
import 'package:med_sync/features/auth/views/forgot_password_view.dart';
import 'package:med_sync/features/auth/views/login_view.dart';
import 'package:med_sync/features/auth/views/profile_view.dart';
import 'package:med_sync/features/auth/views/signup_view.dart';
import 'package:med_sync/features/auth/views/splash_view.dart';
import 'package:med_sync/features/dose_tracking/views/missed_dose_screen.dart';
import 'package:med_sync/features/home/views/home_screen.dart';
import 'package:med_sync/features/medications/views/add_medication_screen.dart';
import 'package:med_sync/features/medications/views/medication_detail_screen.dart';
import 'package:med_sync/features/medications/views/medications_list_screen.dart';
import 'package:med_sync/features/progress/views/progress_screen.dart';
import 'package:med_sync/features/settings/views/settings_screen.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part '../../generated/core/routing/app_router.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {
  final refreshNotifier = _RouterRefreshNotifier();

  ref
    ..onDispose(refreshNotifier.dispose)
    ..listen(currentUserProvider, (_, _) => refreshNotifier.notify());

  final router = GoRouter(
    initialLocation: SplashView.routePath,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final path = state.uri.path;
      final currentUser = ref.read(currentUserProvider);

      if (currentUser.isLoading) {
        return authRedirectPath(path: path, authState: AuthRouteState.loading);
      }

      final user = currentUser.value;
      if (user == null) {
        return authRedirectPath(
          path: path,
          authState: AuthRouteState.signedOut,
        );
      }

      final usesPassword = user.providerData.any(
        (provider) => provider.providerId == 'password',
      );
      final needsEmailVerification = usesPassword && !user.emailVerified;
      if (needsEmailVerification) {
        return authRedirectPath(
          path: path,
          authState: AuthRouteState.needsEmailVerification,
        );
      }

      return authRedirectPath(path: path, authState: AuthRouteState.signedIn);
    },
    routes: [
      GoRoute(
        path: SplashView.routePath,
        name: SplashView.routeName,
        builder: (context, state) => const SplashView(),
      ),
      GoRoute(
        path: AuthLandingView.routePath,
        name: AuthLandingView.routeName,
        builder: (context, state) => const AuthLandingView(),
      ),
      GoRoute(
        path: LoginView.routePath,
        name: LoginView.routeName,
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: SignUpView.routePath,
        name: SignUpView.routeName,
        builder: (context, state) => const SignUpView(),
      ),
      GoRoute(
        path: ForgotPasswordView.routePath,
        name: ForgotPasswordView.routeName,
        builder: (context, state) => const ForgotPasswordView(),
      ),
      GoRoute(
        path: EmailVerificationView.routePath,
        name: EmailVerificationView.routeName,
        builder: (context, state) => const EmailVerificationView(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: HomeScreen.routePath,
                name: HomeScreen.routeName,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: ProgressScreen.routePath,
                name: ProgressScreen.routeName,
                builder: (context, state) => const ProgressScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: MedicationsListScreen.routePath,
                name: MedicationsListScreen.routeName,
                builder: (context, state) => const MedicationsListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: SettingsScreen.routePath,
                name: SettingsScreen.routeName,
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AddMedicationScreen.routePath,
        name: AddMedicationScreen.routeName,
        builder: (context, state) => const AddMedicationScreen(),
      ),
      GoRoute(
        path: MedicationDetailScreen.routePath,
        name: MedicationDetailScreen.routeName,
        builder: (context, state) => MedicationDetailScreen(
          medicationId: state.pathParameters['medicationId'] ?? '',
        ),
      ),
      GoRoute(
        path: MissedDoseScreen.routePath,
        name: MissedDoseScreen.routeName,
        builder: (context, state) => const MissedDoseScreen(),
      ),
      GoRoute(
        path: ProfileView.routePath,
        name: ProfileView.routeName,
        builder: (context, state) => const ProfileView(),
      ),
      GoRoute(
        path: ChangePasswordView.routePath,
        name: ChangePasswordView.routeName,
        builder: (context, state) => const ChangePasswordView(),
      ),
      GoRoute(
        path: DeleteAccountView.routePath,
        name: DeleteAccountView.routeName,
        builder: (context, state) => const DeleteAccountView(),
      ),
    ],
  );

  ref.onDispose(router.dispose);

  return router;
}

class _RouterRefreshNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}
