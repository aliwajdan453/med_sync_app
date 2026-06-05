import 'package:flutter/material.dart';
import 'package:med_sync/core/base_failure.dart';
import 'package:med_sync/core/errors/app_failure_mapper.dart';
import 'package:med_sync/core/logging/app_logger.dart';
import 'package:med_sync/features/auth/models/profile_screen_state.dart';
import 'package:med_sync/features/auth/state/auth_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part '../../../generated/features/auth/state/profile_screen_notifier.g.dart';

@riverpod
class ProfileScreenNotifier extends _$ProfileScreenNotifier {
  GlobalKey<FormState>? _formKey;
  TextEditingController? _nameController;
  FocusNode? _nameFocus;
  String? _loadedUid;

  GlobalKey<FormState> get formKey => _formKey!;
  TextEditingController get nameController => _nameController!;
  FocusNode get nameFocus => _nameFocus!;

  @override
  Future<ProfileScreenState> build() async {
    _formKey ??= GlobalKey<FormState>();
    _nameController ??= TextEditingController();
    _nameFocus ??= FocusNode();

    ref.onDispose(() {
      _nameController?.dispose();
      _nameController = null;
      _nameFocus?.dispose();
      _nameFocus = null;
      _formKey = null;
      _loadedUid = null;
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

    if (_loadedUid != profile.uid) {
      _loadedUid = profile.uid;
      _nameController!.text = profile.displayName;
    }

    return ProfileScreenState(profile: profile);
  }

  Future<bool> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) return false;
    return updateDisplayName(_nameController!.text);
  }

  Future<bool> updateDisplayName(String displayName) async {
    final value = displayName.trim();
    if (value.isEmpty) {
      if (!state.hasValue) return false;
      state = AsyncData(
        state.requireValue.copyWith(
          actionFailure: const BaseFailure(
            title: 'Check fields',
            description: 'Check the highlighted fields.',
            fieldErrors: {'displayName': 'Enter your name.'},
          ),
        ),
      );
      return false;
    }

    if (!state.hasValue) return false;
    state = AsyncData(
      state.requireValue.copyWith(isSubmitting: true, actionFailure: null),
    );

    try {
      final user = ref.read(authRepositoryProvider).currentUser;
      if (user == null) {
        throw const BaseFailure(
          title: 'Session unavailable',
          description: 'We could not find your signed-in session.',
          diagnosticCode: 'missing-current-user',
        );
      }
      final updatedProfile = await ref
          .read(profileRepositoryProvider)
          .updateDisplayName(user: user, displayName: value);
      if (!ref.mounted) return true;
      state = AsyncData(
        state.requireValue.copyWith(
          profile: updatedProfile,
          isSubmitting: false,
          actionFailure: null,
        ),
      );
      return true;
    } on Object catch (error, stackTrace) {
      if (!ref.mounted) return false;
      state = AsyncData(
        state.requireValue.copyWith(
          isSubmitting: false,
          actionFailure: AppFailureMapper.map(
            error,
            stackTrace: stackTrace,
            logger: ref.read(appLoggerProvider('auth.profile')),
          ),
        ),
      );
      return false;
    }
  }

  void clearActionFailure() {
    if (!state.hasValue) return;
    state = AsyncData(state.requireValue.copyWith(actionFailure: null));
  }

  Future<bool> signOut() async {
    try {
      await ref.read(authRepositoryProvider).signOut();
      return true;
    } on Object catch (error, stackTrace) {
      if (!ref.mounted) return false;
      if (state.hasValue) {
        state = AsyncData(
          state.requireValue.copyWith(
            actionFailure: AppFailureMapper.map(
              error,
              stackTrace: stackTrace,
              logger: ref.read(appLoggerProvider('auth.profile')),
            ),
          ),
        );
      }
      return false;
    }
  }
}
