import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:med_sync/core/base_failure.dart';
import 'package:med_sync/features/auth/models/user_profile.dart';

part '../../../generated/features/auth/models/delete_account_screen_state.freezed.dart';

@freezed
abstract class DeleteAccountScreenState with _$DeleteAccountScreenState {
  const factory DeleteAccountScreenState({
    required UserProfile profile,
    @Default(false) bool isSubmitting,
    BaseFailure? actionFailure,
  }) = _DeleteAccountScreenState;
}
