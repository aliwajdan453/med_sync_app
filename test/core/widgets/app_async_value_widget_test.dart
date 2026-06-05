import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_sync/core/base_failure.dart';
import 'package:med_sync/core/widgets/app_async_value_widget.dart';

void main() {
  testWidgets('shows default loading, error diagnostics, and retry', (
    tester,
  ) async {
    var retryCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppAsyncValueWidget<int>(
            value: AsyncValue<int>.error(
              StateError('load failed'),
              StackTrace.fromString('stack-line'),
            ),
            onRetry: () => retryCount += 1,
            data: (context, value) => Text('$value'),
          ),
        ),
      ),
    );

    expect(find.text('We could not load this content.'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    expect(find.textContaining('stack-line'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    expect(retryCount, 1);
  });

  testWidgets('shows base failure title and description', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppAsyncValueWidget<int>(
            value: AsyncError<int>(
              BaseFailure(
                title: 'Load failed',
                description: 'Use a stable connection and try again.',
              ),
              StackTrace.empty,
            ),
            data: _IntDataView.new,
          ),
        ),
      ),
    );

    expect(find.text('Load failed'), findsOneWidget);
    expect(find.text('Use a stable connection and try again.'), findsOneWidget);
    expect(find.text('We could not load this content.'), findsNothing);
  });
}

class _IntDataView extends StatelessWidget {
  const _IntDataView(this.context, this.value);

  final BuildContext context;
  final int value;

  @override
  Widget build(BuildContext context) => Text('$value');
}
