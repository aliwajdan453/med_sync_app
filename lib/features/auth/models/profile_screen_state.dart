import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:med_sync/core/base_failure.dart';
import 'package:med_sync/features/auth/models/user_profile.dart';

part '../../../generated/features/auth/models/profile_screen_state.freezed.dart';

@freezed
abstract class ProfileScreenState with _$ProfileScreenState {
  const factory ProfileScreenState({
    required UserProfile profile,
    @Default(false) bool isSubmitting,
    BaseFailure? actionFailure,
  }) = _ProfileScreenState;
}
