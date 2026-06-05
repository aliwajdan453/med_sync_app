import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part '../../generated/core/logging/app_logger.g.dart';

@Riverpod(keepAlive: true)
AppLogger appLogger(Ref ref, String name) => DeveloperAppLogger(name);

abstract interface class AppLogger {
  void info(String message, {Map<String, Object?> context = const {}});

  void warning(String message, {Map<String, Object?> context = const {}});

  void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> context = const {},
  });
}

class DeveloperAppLogger implements AppLogger {
  const DeveloperAppLogger(this.name);

  final String name;

  @override
  void info(String message, {Map<String, Object?> context = const {}}) {
    _log(message, level: 800, context: context);
  }

  @override
  void warning(String message, {Map<String, Object?> context = const {}}) {
    _log(message, level: 900, context: context);
  }

  @override
  void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> context = const {},
  }) {
    _log(
      message,
      level: 1000,
      error: error,
      stackTrace: stackTrace,
      context: context,
    );
  }

  void _log(
    String message, {
    required int level,
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> context = const {},
  }) {
    if (!kDebugMode) return;

    developer.log(
      _messageWithContext(message, context),
      name: name,
      level: level,
      error: error,
      stackTrace: stackTrace,
    );
  }

  String _messageWithContext(String message, Map<String, Object?> context) {
    if (context.isEmpty) return message;

    final entries = context.entries
        .map((entry) => '${entry.key}=${entry.value}')
        .join(' ');

    return '$message | $entries';
  }
}
