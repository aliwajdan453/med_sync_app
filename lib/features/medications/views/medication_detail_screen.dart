import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_sync/core/design_system/base_app_bar.dart';
import 'package:med_sync/core/design_system/base_scaffold.dart';
import 'package:med_sync/core/navigation/app_navigator.dart';
import 'package:med_sync/core/theme/app_colors.dart';
import 'package:med_sync/core/widgets/app_async_value_widget.dart';
import 'package:med_sync/core/widgets/app_error_banner.dart';
import 'package:med_sync/features/medications/models/medication.dart';
import 'package:med_sync/features/medications/models/medication_detail_state.dart';
import 'package:med_sync/features/medications/models/medication_form_state.dart';
import 'package:med_sync/features/medications/state/medication_controllers.dart';
import 'package:med_sync/features/medications/views/medications_list_screen.dart';
import 'package:med_sync/features/medications/widgets/medication_form.dart';

class MedicationDetailScreen extends ConsumerWidget {
  const MedicationDetailScreen({required this.medicationId, super.key});

  static const routeName = 'medication-detail';
  static const routePath = '/medications/:medicationId';

  final String medicationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifierState = ref.watch(
      medicationDetailScreenProvider(medicationId),
    );
    final navigator = ref.read(appNavigatorProvider);

    ref.listen(medicationDetailScreenProvider(medicationId), (_, next) {
      if (next.value?.didCompleteDelete == true) {
        navigator.go(MedicationsListScreen.routePath);
      }
    });

    return BaseScaffold(
      appBar: BaseAppBar(
        title: 'Medication',
        trailing: notifierState.whenOrNull(
          data: (state) => IconButton(
            tooltip: state.isEditing ? 'Cancel edit' : 'Edit',
            onPressed: () {
              if (state.isEditing) {
                ref
                    .read(medicationDetailScreenProvider(medicationId).notifier)
                    .cancelEditing();
              } else {
                ref
                    .read(medicationDetailScreenProvider(medicationId).notifier)
                    .startEditing();
              }
            },
            icon: Icon(state.isEditing ? Icons.close : Icons.edit_outlined),
          ),
        ),
      ),
      child: AppAsyncValueWidget<MedicationDetailState>(
        value: notifierState,
        onRetry: () =>
            ref.invalidate(medicationDetailScreenProvider(medicationId)),
        data: (context, state) {
          if (state.actionFailure != null) {
            return Column(
              children: [
                AppErrorBanner(message: state.actionFailure!.description),
                Expanded(child: _buildBody(context, ref, state, navigator)),
              ],
            );
          }
          return _buildBody(context, ref, state, navigator);
        },
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    MedicationDetailState state,
    AppNavigator navigator,
  ) {
    if (state.isEditing) {
      return MedicationForm(
        state: MedicationFormState(isSubmitting: state.isSubmitting),
        initialMedication: state.medication,
        onSubmit: (input) => ref
            .read(medicationDetailScreenProvider(medicationId).notifier)
            .saveEdit(input),
      );
    }
    return _MedicationDetail(
      medication: state.medication,
      isSubmitting: state.isSubmitting,
      onArchive: () => _archive(context, ref, navigator),
      onDelete: () => _delete(context, ref, navigator),
    );
  }

  Future<void> _archive(
    BuildContext context,
    WidgetRef ref,
    AppNavigator navigator,
  ) async {
    final confirmed = await _confirm(
      context,
      title: 'Archive medication?',
      message: 'Archived medications are hidden from active routine lists.',
      action: 'Archive',
    );
    if (!confirmed) return;
    final archived = await ref
        .read(medicationDetailScreenProvider(medicationId).notifier)
        .archive();
    if (archived && context.mounted) {
      navigator.go(MedicationsListScreen.routePath);
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    AppNavigator navigator,
  ) async {
    final confirmed = await _confirm(
      context,
      title: 'Permanently delete?',
      message: 'This removes the medication record from Firestore.',
      action: 'Delete',
    );
    if (!confirmed) return;
    await ref
        .read(medicationDetailScreenProvider(medicationId).notifier)
        .permanentlyDelete();
  }

  Future<bool> _confirm(
    BuildContext context, {
    required String title,
    required String message,
    required String action,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => PopScope(
        canPop: false,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12.0),
                Text(
                  message,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.slateLabel),
                ),
                const SizedBox(height: 24.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8.0),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text(action),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    return result ?? false;
  }
}

class _MedicationDetail extends StatelessWidget {
  const _MedicationDetail({
    required this.medication,
    required this.isSubmitting,
    required this.onArchive,
    required this.onDelete,
  });

  final Medication medication;
  final bool isSubmitting;
  final VoidCallback onArchive;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(24.0),
    children: [
      Text(
        medication.name,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(
          context,
        ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 8.0),
      Text(
        '${_formatNumber(medication.doseAmount)} ${medication.doseUnit}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 16.0),
      _DetailRow(label: 'Category', value: medication.category.name),
      const SizedBox(height: 8.0),
      _DetailRow(label: 'Routine', value: _routineLabel(medication)),
      const SizedBox(height: 8.0),
      _DetailRow(label: 'Instructions', value: medication.instructions),
      if (medication.refillInfo != null) ...[
        const SizedBox(height: 8.0),
        _DetailRow(
          label: 'Supply',
          value:
              '${_formatNumber(medication.refillInfo!.currentQuantity)} remaining, '
              'threshold ${_formatNumber(medication.refillInfo!.reminderThreshold)}',
        ),
      ],
      const SizedBox(height: 24.0),
      FilledButton.tonalIcon(
        onPressed: isSubmitting ? null : onArchive,
        icon: const Icon(Icons.archive_outlined),
        label: const Text('Archive medication'),
      ),
      const SizedBox(height: 12.0),
      TextButton.icon(
        onPressed: isSubmitting ? null : onDelete,
        icon: const Icon(Icons.delete_outline),
        label: const Text('Permanently delete'),
      ),
    ],
  );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: AppColors.slateLabel,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 4.0),
      Text(value, maxLines: 3, overflow: TextOverflow.ellipsis),
    ],
  );
}

String _routineLabel(Medication medication) {
  if (medication.routineType == MedicationRoutineType.asNeeded) {
    return 'As needed';
  }
  final schedule = medication.schedule;
  if (schedule == null) return 'Scheduled';
  final pattern = schedule.pattern == MedicationSchedulePattern.daily
      ? 'Daily'
      : 'Selected weekdays';
  final times = schedule.times.map((t) => t.label).join(', ');
  return '$pattern at $times';
}

String _formatNumber(double value) {
  if (value == value.roundToDouble()) return value.toInt().toString();
  return value.toString();
}
