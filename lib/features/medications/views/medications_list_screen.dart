import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_sync/core/design_system/base_app_bar.dart';
import 'package:med_sync/core/design_system/base_scaffold.dart';
import 'package:med_sync/core/navigation/app_navigator.dart';
import 'package:med_sync/core/theme/app_colors.dart';
import 'package:med_sync/core/widgets/app_async_value_widget.dart';
import 'package:med_sync/features/medications/models/medication.dart';
import 'package:med_sync/features/medications/state/medication_providers.dart';
import 'package:med_sync/features/medications/views/add_medication_screen.dart';
import 'package:med_sync/features/medications/views/medication_detail_screen.dart';

class MedicationsListScreen extends ConsumerWidget {
  const MedicationsListScreen({super.key});

  static const routeName = 'medications';
  static const routePath = '/medications';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medications = ref.watch(medicationListProvider);
    final navigator = ref.read(appNavigatorProvider);

    return BaseScaffold(
      appBar: const BaseAppBar(title: 'Medications', showLeading: false),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => navigator.push(AddMedicationScreen.routePath),
        icon: const Icon(Icons.add),
        label: const Text('Add medication'),
      ),
      child: AppAsyncValueWidget<List<Medication>>(
        value: medications,
        onRetry: () => ref.invalidate(medicationListProvider),
        data: (context, value) => value.isEmpty
            ? _EmptyMedicationList(
                onAdd: () => navigator.push(AddMedicationScreen.routePath),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(24.0),
                itemCount: value.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12.0),
                itemBuilder: (_, i) => _MedicationCard(
                  medication: value[i],
                  onTap: () => navigator.pushNamed(
                    MedicationDetailScreen.routeName,
                    pathParameters: {'medicationId': value[i].id},
                  ),
                ),
              ),
      ),
    );
  }
}

class _EmptyMedicationList extends StatelessWidget {
  const _EmptyMedicationList({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.medication_outlined,
            size: 44.0,
            color: AppColors.primary.withValues(alpha: 0.8),
          ),
          const SizedBox(height: 16.0),
          Text(
            'No medications yet',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8.0),
          Text(
            'Add scheduled or as-needed routines when you are ready.',
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.slateLabel),
          ),
          const SizedBox(height: 20.0),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Add medication'),
          ),
        ],
      ),
    ),
  );
}

class _MedicationCard extends StatelessWidget {
  const _MedicationCard({required this.medication, required this.onTap});

  final Medication medication;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      onTap: onTap,
      title: Text(
        medication.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        _subtitle(medication),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.chevron_right),
    ),
  );
}

String _subtitle(Medication medication) {
  final routine = medication.routineType == MedicationRoutineType.scheduled
      ? 'Scheduled'
      : 'As needed';

  return '$routine • ${_formatNumber(medication.doseAmount)} ${medication.doseUnit}';
}

String _formatNumber(double value) {
  if (value == value.roundToDouble()) return value.toInt().toString();

  return value.toString();
}
