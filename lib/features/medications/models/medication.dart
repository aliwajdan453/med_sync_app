import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:med_sync/core/converters/firestore_datetime_converter.dart';
import 'package:med_sync/core/types.dart';

part '../../../generated/features/medications/models/medication.freezed.dart';
part '../../../generated/features/medications/models/medication.g.dart';

enum MedicationCategory { prescription, otc, supplement }

enum MedicationRoutineType { scheduled, asNeeded }

enum MedicationStatus { active, archived }

enum MedicationSchedulePattern { daily, weekdays }

@freezed
abstract class MedicationTime with _$MedicationTime {
  const MedicationTime._();

  const factory MedicationTime({required int hour, required int minute}) =
      _MedicationTime;

  factory MedicationTime.fromJson(Json json) => _$MedicationTimeFromJson(json);

  String get label {
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final suffix = hour >= 12 ? 'PM' : 'AM';
    return '$displayHour:${minute.toString().padLeft(2, '0')} $suffix';
  }
}

@freezed
abstract class MedicationSchedule with _$MedicationSchedule {
  @JsonSerializable(explicitToJson: true)
  const factory MedicationSchedule({
    required MedicationSchedulePattern pattern,
    @Default(<int>[]) List<int> weekdays,
    @Default(<MedicationTime>[]) List<MedicationTime> times,
  }) = _MedicationSchedule;

  factory MedicationSchedule.fromJson(Json json) =>
      _$MedicationScheduleFromJson(json);
}

@freezed
abstract class RefillInfo with _$RefillInfo {
  const factory RefillInfo({
    required double currentQuantity,
    required double doseQuantity,
    required double reminderThreshold,
  }) = _RefillInfo;

  factory RefillInfo.fromJson(Json json) => _$RefillInfoFromJson(json);
}

@freezed
abstract class Medication with _$Medication {
  @JsonSerializable(explicitToJson: true)
  const factory Medication({
    required String id,
    required String ownerUid,
    required String name,
    required MedicationCategory category,
    required MedicationRoutineType routineType,
    required MedicationStatus status,
    required double doseAmount,
    required String doseUnit,
    required String instructions,
    @FirestoreDateTimeConverter() required DateTime createdAt,
    @FirestoreDateTimeConverter() required DateTime updatedAt,
    MedicationSchedule? schedule,
    RefillInfo? refillInfo,
    @NullableFirestoreDateTimeConverter() DateTime? archivedAt,
    @NullableFirestoreDateTimeConverter() DateTime? deletedAt,
  }) = _Medication;

  factory Medication.fromJson(Json json) => _$MedicationFromJson(json);
}

@freezed
abstract class MedicationFormInput with _$MedicationFormInput {
  @JsonSerializable(explicitToJson: true)
  const factory MedicationFormInput({
    required String name,
    required MedicationCategory category,
    required MedicationRoutineType routineType,
    required double? doseAmount,
    required String doseUnit,
    required String customDoseUnit,
    required String instructions,
    required MedicationSchedule? schedule,
    required RefillInfo? refillInfo,
  }) = _MedicationFormInput;

  factory MedicationFormInput.fromJson(Json json) =>
      _$MedicationFormInputFromJson(json);
}

const doseUnitOptions = <String>[
  'mg',
  'mcg',
  'g',
  'mL',
  'IU',
  'tablet',
  'capsule',
  'drop',
  'puff',
  'custom',
];
