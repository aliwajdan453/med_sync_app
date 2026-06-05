import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:med_sync/core/base_failure.dart';
import 'package:med_sync/core/errors/app_failure_mapper.dart';
import 'package:med_sync/core/logging/app_logger.dart';
import 'package:med_sync/features/auth/data/auth_repository.dart';
import 'package:med_sync/features/auth/models/user_profile.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._auth, {AppLogger? logger})
    : _logger = logger ?? const DeveloperAppLogger('auth.firebase');

  final FirebaseAuth _auth;
  final AppLogger _logger;

  static Future<void>? _googleInitializeFuture;

  @override
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  @override
  User? get currentUser => _auth.currentUser;

  @override
  Future<User> signUpWithEmail({
    required String displayName,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = _requireUser(credential.user);
      await user.updateDisplayName(displayName.trim());
      await user.reload();
      return _requireUser(_auth.currentUser);
    } on Object catch (error) {
      throw AppFailureMapper.map(error, logger: _logger);
    }
  }

  @override
  Future<User> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return _requireUser(credential.user);
    } on Object catch (error) {
      throw AppFailureMapper.map(error, logger: _logger);
    }
  }

  @override
  Future<User> signInWithGoogle() async {
    try {
      await _ensureGoogleInitialized();
      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;

      if (idToken == null) {
        throw _providerConfigurationFailure(
          diagnosticCode: 'missing-google-id-token',
          diagnosticMessage: 'Google Sign-In returned no ID token.',
        );
      }

      final credential = GoogleAuthProvider.credential(idToken: idToken);
      final userCredential = await _auth.signInWithCredential(credential);
      return _requireUser(userCredential.user);
    } on GoogleSignInException catch (error) {
      throw _mapGoogleException(error);
    } on Object catch (error) {
      throw AppFailureMapper.map(error, logger: _logger);
    }
  }

  @override
  Future<User> signInWithApple() async {
    try {
      final rawNonce = _generateNonce();
      final credential = await _getAppleCredential(rawNonce);
      final idToken = credential.identityToken;

      if (idToken == null) {
        throw _providerConfigurationFailure(
          diagnosticCode: 'missing-apple-id-token',
          diagnosticMessage: 'Apple Sign-In returned no identity token.',
        );
      }

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: idToken,
        rawNonce: rawNonce,
        accessToken: credential.authorizationCode,
      );
      final userCredential = await _auth.signInWithCredential(oauthCredential);
      return _requireUser(userCredential.user);
    } on SignInWithAppleAuthorizationException catch (error) {
      throw _mapAppleException(error);
    } on SignInWithAppleException catch (error) {
      throw _providerConfigurationFailure(
        diagnosticCode: 'sign-in-with-apple',
        diagnosticMessage: error.toString(),
      );
    } on Object catch (error) {
      throw AppFailureMapper.map(error, logger: _logger);
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on Object catch (error) {
      throw AppFailureMapper.map(error, logger: _logger);
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      final user = _requireUser(_auth.currentUser);
      if (!user.emailVerified) {
        await user.sendEmailVerification();
      }
    } on Object catch (error) {
      throw AppFailureMapper.map(error, logger: _logger);
    }
  }

  @override
  Future<void> reloadCurrentUser() async {
    try {
      await _auth.currentUser?.reload();
    } on Object catch (error) {
      throw AppFailureMapper.map(error, logger: _logger);
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _requireUser(_auth.currentUser);
      final email = user.email;
      if (email == null) {
        throw _providerConfigurationFailure(
          diagnosticCode: 'missing-email',
          diagnosticMessage: 'Password account has no email.',
        );
      }
      await user.reauthenticateWithCredential(
        EmailAuthProvider.credential(email: email, password: currentPassword),
      );
      await user.updatePassword(newPassword);
    } on Object catch (error) {
      throw AppFailureMapper.map(error, logger: _logger);
    }
  }

  @override
  Future<void> reauthenticateForDeletion({
    required UserProfile profile,
    String? password,
  }) async {
    try {
      final user = _requireUser(_auth.currentUser);
      if (profile.deleteReauthMode == DeleteReauthMode.password) {
        final value = password;
        if (value == null || value.isEmpty) {
          throw const BaseFailure(
            title: 'Check fields',
            description: 'Check the highlighted fields.',
            fieldErrors: {'password': 'Enter your password.'},
          );
        }
        await user.reauthenticateWithCredential(
          EmailAuthProvider.credential(email: profile.email, password: value),
        );
        return;
      }

      if (profile.providerIds.contains('google.com')) {
        await _reauthenticateWithGoogle(user);
        return;
      }

      if (profile.providerIds.contains('apple.com')) {
        await _reauthenticateWithApple(user);
        return;
      }

      throw _providerConfigurationFailure(
        diagnosticCode: 'unsupported-reauth-provider',
        diagnosticMessage: profile.providerIds.join(','),
      );
    } on Object catch (error) {
      throw AppFailureMapper.map(error, logger: _logger);
    }
  }

  @override
  Future<void> deleteCurrentUser() async {
    try {
      await _requireUser(_auth.currentUser).delete();
    } on Object catch (error) {
      throw AppFailureMapper.map(error, logger: _logger);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _ensureGoogleInitialized();
      await GoogleSignIn.instance.signOut();
    } on Object {
      // Firebase sign-out must still run even if Google has no local session.
    }
    await _auth.signOut();
  }

  Future<void> _reauthenticateWithGoogle(User user) async {
    await _ensureGoogleInitialized();
    final account = await GoogleSignIn.instance.authenticate();
    final idToken = account.authentication.idToken;
    if (idToken == null) {
      throw _providerConfigurationFailure(
        diagnosticCode: 'missing-google-id-token',
        diagnosticMessage: 'Google reauth returned no ID token.',
      );
    }
    await user.reauthenticateWithCredential(
      GoogleAuthProvider.credential(idToken: idToken),
    );
  }

  Future<void> _reauthenticateWithApple(User user) async {
    final rawNonce = _generateNonce();
    final credential = await _getAppleCredential(rawNonce);
    final idToken = credential.identityToken;
    if (idToken == null) {
      throw _providerConfigurationFailure(
        diagnosticCode: 'missing-apple-id-token',
        diagnosticMessage: 'Apple reauth returned no identity token.',
      );
    }
    await user.reauthenticateWithCredential(
      OAuthProvider('apple.com').credential(
        idToken: idToken,
        rawNonce: rawNonce,
        accessToken: credential.authorizationCode,
      ),
    );
  }

  Future<AuthorizationCredentialAppleID> _getAppleCredential(String rawNonce) =>
      SignInWithApple.getAppleIDCredential(
        scopes: const [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: _sha256ofString(rawNonce),
      );

  static Future<void> _ensureGoogleInitialized() =>
      _googleInitializeFuture ??= GoogleSignIn.instance.initialize();

  static User _requireUser(User? user) {
    if (user == null) {
      throw _missingSessionFailure();
    }
    return user;
  }

  static BaseFailure _mapGoogleException(GoogleSignInException error) {
    if (error.code == GoogleSignInExceptionCode.canceled ||
        error.code == GoogleSignInExceptionCode.interrupted) {
      return _providerCanceledFailure();
    }

    return _providerConfigurationFailure(
      diagnosticCode: error.code.name,
      diagnosticMessage: error.description,
    );
  }

  static BaseFailure _mapAppleException(
    SignInWithAppleAuthorizationException error,
  ) {
    if (error.code == AuthorizationErrorCode.canceled) {
      return _providerCanceledFailure();
    }

    return _providerConfigurationFailure(
      diagnosticCode: error.code.name,
      diagnosticMessage: error.message,
    );
  }

  static BaseFailure _providerCanceledFailure() => const BaseFailure(
    title: 'Sign in canceled',
    description: 'Sign in was canceled.',
  );

  static BaseFailure _providerConfigurationFailure({
    String? diagnosticCode,
    String? diagnosticMessage,
  }) => BaseFailure(
    title: 'Sign in unavailable',
    description: 'This sign-in option is not configured yet.',
    diagnosticCode: diagnosticCode,
    diagnosticMessage: diagnosticMessage,
  );

  static BaseFailure _missingSessionFailure() => const BaseFailure(
    title: 'Session unavailable',
    description: 'We could not find your signed-in session.',
    diagnosticCode: 'missing-current-user',
  );

  static String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  static String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    return sha256.convert(bytes).toString();
  }
}
