import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:med_sync/core/types.dart';

part '../../../generated/features/auth/models/user_profile.freezed.dart';
part '../../../generated/features/auth/models/user_profile.g.dart';

enum DeleteReauthMode { password, provider }

class FirestoreDateTimeConverter implements JsonConverter<DateTime, Object?> {
  const FirestoreDateTimeConverter();

  @override
  DateTime fromJson(Object? json) {
    if (json is Timestamp) {
      return json.toDate();
    }
    if (json is String) {
      return DateTime.parse(json);
    }
    if (json is DateTime) {
      return json;
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  @override
  Object toJson(DateTime object) => Timestamp.fromDate(object);
}

@freezed
abstract class UserProfile with _$UserProfile {
  const UserProfile._();

  const factory UserProfile({
    required String uid,
    required String displayName,
    required String email,
    @FirestoreDateTimeConverter() required DateTime createdAt,
    @FirestoreDateTimeConverter() required DateTime updatedAt,
    @FirestoreDateTimeConverter() required DateTime lastLoginAt,
    String? photoUrl,
    @Default(<String>[]) List<String> providerIds,
    @Default(false) bool emailVerified,
  }) = _UserProfile;

  factory UserProfile.fromJson(Json json) => _$UserProfileFromJson(json);

  bool get hasPasswordProvider => providerIds.contains('password');

  DeleteReauthMode get deleteReauthMode => hasPasswordProvider
      ? DeleteReauthMode.password
      : DeleteReauthMode.provider;
}
