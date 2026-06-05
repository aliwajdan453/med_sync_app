import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_sync/core/design_system/base_app_bar.dart';
import 'package:med_sync/core/design_system/base_scaffold.dart';
import 'package:med_sync/core/navigation/app_navigator.dart';
import 'package:med_sync/features/medications/models/medication.dart';
import 'package:med_sync/features/medications/state/add_medication_controller.dart';
import 'package:med_sync/features/medications/views/medication_detail_screen.dart';
import 'package:med_sync/features/medications/widgets/medication_form.dart';

class AddMedicationScreen extends ConsumerWidget {
  const AddMedicationScreen({super.key});

  static const routeName = 'add-medication';
  static const routePath = '/medications/add';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(addMedicationControllerProvider);

    return BaseScaffold(
      appBar: const BaseAppBar(title: 'Add Medication'),
      child: MedicationForm(
        state: state,
        onSubmit: (input) => _save(context, ref, input),
      ),
    );
  }

  Future<void> _save(
    BuildContext context,
    WidgetRef ref,
    MedicationFormInput input,
  ) async {
    final medicationId = await ref
        .read(addMedicationControllerProvider.notifier)
        .save(input);

    if (!context.mounted || medicationId == null) return;

    ref
        .read(appNavigatorProvider)
        .goNamed(
          MedicationDetailScreen.routeName,
          pathParameters: {'medicationId': medicationId},
        );
  }
}
