import 'package:freezed_annotation/freezed_annotation.dart';

part '../generated/core/base_failure.freezed.dart';

@freezed
abstract class BaseFailure with _$BaseFailure implements Exception {
  const BaseFailure._();

  const factory BaseFailure({
    required String title,
    required String description,
    @Default(<String, String>{}) Map<String, String> fieldErrors,
    String? diagnosticCode,
    String? diagnosticMessage,
    Object? error,
    StackTrace? stackTrace,
  }) = _BaseFailure;
}
