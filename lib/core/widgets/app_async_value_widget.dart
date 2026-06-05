import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_sync/core/base_failure.dart';
import 'package:med_sync/core/theme/app_colors.dart';

typedef AsyncDataBuilder<T> = Widget Function(BuildContext context, T value);
typedef AsyncLoadingBuilder = Widget Function(BuildContext context);
typedef AsyncErrorBuilder =
    Widget Function(BuildContext context, Object error, StackTrace stackTrace);

class AppAsyncValueWidget<T> extends StatelessWidget {
  const AppAsyncValueWidget({
    required this.value,
    required this.data,
    this.loading,
    this.error,
    this.onRetry,
    super.key,
  });

  final AsyncValue<T> value;
  final AsyncDataBuilder<T> data;
  final AsyncLoadingBuilder? loading;
  final AsyncErrorBuilder? error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => value.when(
    data: (loaded) => data(context, loaded),
    loading: () => loading?.call(context) ?? const _DefaultLoadingState(),
    error: (failure, stackTrace) =>
        error?.call(context, failure, stackTrace) ??
        _DefaultErrorState(
          error: failure,
          stackTrace: stackTrace,
          onRetry: onRetry,
        ),
  );
}

class _DefaultLoadingState extends StatelessWidget {
  const _DefaultLoadingState();

  @override
  Widget build(BuildContext context) => const Center(
    child: Padding(
      padding: EdgeInsets.all(32),
      child: CircularProgressIndicator(),
    ),
  );
}

class _DefaultErrorState extends StatelessWidget {
  const _DefaultErrorState({
    required this.error,
    required this.stackTrace,
    required this.onRetry,
  });

  final Object error;
  final StackTrace stackTrace;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final failure = error is BaseFailure ? error as BaseFailure : null;

    return Center(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(24.0),
          boxShadow: [
            BoxShadow(
              color: AppColors.navyText.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                failure?.title ?? 'We could not load this content.',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                failure?.description ?? 'Check your connection and try again.',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.slateLabel,
                ),
              ),
              if (kDebugMode) ...[
                const SizedBox(height: 12),
                Text(
                  '$error\n$stackTrace',
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.slateLabel,
                  ),
                ),
              ],
              if (onRetry != null) ...[
                const SizedBox(height: 16),
                FilledButton(onPressed: onRetry, child: const Text('Retry')),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
