import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:med_sync/core/theme/app_colors.dart';

class AppErrorBanner extends StatelessWidget {
  const AppErrorBanner({
    required this.message,
    this.diagnosticCode,
    this.diagnosticMessage,
    this.stackTrace,
    super.key,
  });

  final String? message;
  final String? diagnosticCode;
  final String? diagnosticMessage;
  final StackTrace? stackTrace;

  @override
  Widget build(BuildContext context) {
    final value = message;

    if (value == null || value.isEmpty) return const SizedBox.shrink();

    return Semantics(
      liveRegion: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.navyText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (kDebugMode && _diagnosticText.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        _diagnosticText,
                        maxLines: 8,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.slateLabel,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get _diagnosticText {
    final parts = <String>[];

    final code = diagnosticCode;
    final diagnostic = diagnosticMessage;
    final trace = stackTrace;

    if (code != null && code.isNotEmpty) parts.add('code: $code');

    if (diagnostic != null && diagnostic.isNotEmpty) {
      parts.add('error: $diagnostic');
    }

    if (trace != null) parts.add('stack: $trace');

    return parts.join('\n');
  }
}
