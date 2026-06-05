import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_sync/core/design_system/base_app_bar.dart';
import 'package:med_sync/core/design_system/base_scaffold.dart';
import 'package:med_sync/core/navigation/app_navigator.dart';
import 'package:med_sync/core/theme/app_colors.dart';
import 'package:med_sync/core/widgets/app_async_value_widget.dart';
import 'package:med_sync/features/auth/views/profile_view.dart';
import 'package:med_sync/features/dose_tracking/views/missed_dose_screen.dart';
import 'package:med_sync/features/medications/state/medication_providers.dart';
import 'package:med_sync/features/medications/models/medication.dart';
import 'package:med_sync/features/medications/views/add_medication_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const routeName = 'home';
  static const routePath = '/';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final medications = ref.watch(medicationListProvider);
    final navigator = ref.read(appNavigatorProvider);

    return BaseScaffold(
      appBar: BaseAppBar(
        title: 'Today',
        showLeading: false,
        trailing: IconButton(
          tooltip: 'Profile',
          onPressed: () => navigator.push(ProfileView.routePath),
          icon: const Icon(Icons.person_outline),
        ),
      ),
      child: AppAsyncValueWidget<List<Medication>>(
        value: medications,
        onRetry: () => ref.invalidate(medicationListProvider),
        data: (context, value) => ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            Text(
              'Medication routine',
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Track scheduled and as-needed routines without clinical claims or fake progress data.',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyLarge?.copyWith(
                color: AppColors.slateLabel,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24.0),
            _TodaySummary(medications: value),
            const SizedBox(height: 16.0),
            FilledButton.icon(
              onPressed: () => navigator.push(AddMedicationScreen.routePath),
              icon: const Icon(Icons.add),
              label: const Text('Add medication'),
            ),
            const SizedBox(height: 12.0),
            TextButton.icon(
              onPressed: () => navigator.push(MissedDoseScreen.routePath),
              icon: const Icon(Icons.event_available_outlined),
              label: const Text('Missed dose review'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodaySummary extends StatelessWidget {
  const _TodaySummary({required this.medications});

  final List<Medication> medications;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheduled = medications
        .where((m) => m.routineType == MedicationRoutineType.scheduled)
        .length;
    final asNeeded = medications.length - scheduled;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              medications.isEmpty ? 'No medications yet' : 'Routine summary',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12.0),
            if (medications.isEmpty)
              Text(
                'Add your first scheduled or as-needed routine to start.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.slateLabel,
                ),
              )
            else ...[
              _StatusRow(label: 'Scheduled routines', value: '$scheduled'),
              const SizedBox(height: 12.0),
              _StatusRow(label: 'As-needed routines', value: '$asNeeded'),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyMedium?.copyWith(color: AppColors.slateLabel),
          ),
        ),
        Text(
          value,
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.dataTeal,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
