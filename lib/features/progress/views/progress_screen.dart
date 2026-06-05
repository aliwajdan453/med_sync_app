import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_sync/core/design_system/base_app_bar.dart';
import 'package:med_sync/core/design_system/base_scaffold.dart';
import 'package:med_sync/core/theme/app_colors.dart';
import 'package:med_sync/core/widgets/app_async_value_widget.dart';
import 'package:med_sync/features/medications/state/medication_providers.dart';
import 'package:med_sync/features/medications/models/medication.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  static const routeName = 'progress';
  static const routePath = '/progress';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medications = ref.watch(medicationListProvider);

    return BaseScaffold(
      appBar: const BaseAppBar(title: 'Progress', showLeading: false),
      child: AppAsyncValueWidget<List<Medication>>(
        value: medications,
        onRetry: () => ref.invalidate(medicationListProvider),
        data: (context, value) {
          final scheduledCount = value
              .where((m) => m.routineType == MedicationRoutineType.scheduled)
              .length;
          return ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              Text(
                'Progress starts after scheduled dose tracking is added.',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12.0),
              Text(
                scheduledCount == 0
                    ? 'No scheduled routines are available for progress yet.'
                    : '$scheduledCount scheduled routine${scheduledCount == 1 ? '' : 's'} ready for future progress tracking.',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.slateLabel),
              ),
            ],
          );
        },
      ),
    );
  }
}
