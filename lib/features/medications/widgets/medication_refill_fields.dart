import 'package:flutter/material.dart';
import 'package:med_sync/core/widgets/app_text_field.dart';

class MedicationRefillFields extends StatelessWidget {
  const MedicationRefillFields({
    required this.enabled,
    required this.currentQuantityController,
    required this.doseQuantityController,
    required this.thresholdController,
    required this.errors,
    required this.onEnabledChanged,
    super.key,
  });

  final bool enabled;
  final TextEditingController currentQuantityController;
  final TextEditingController doseQuantityController;
  final TextEditingController thresholdController;
  final Map<String, String> errors;
  final ValueChanged<bool> onEnabledChanged;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      SwitchListTile(
        value: enabled,
        onChanged: onEnabledChanged,
        title: const Text('Track supply'),
        subtitle: const Text('Optional pill-count refill tracking.'),
      ),
      if (enabled) ...[
        const SizedBox(height: 12),
        AppTextField(
          label: 'Remaining Supply',
          controller: currentQuantityController,
          errorText: errors['currentQuantity'],
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        AppTextField(
          label: 'Dose Quantity',
          controller: doseQuantityController,
          errorText: errors['doseQuantity'],
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        AppTextField(
          label: 'Reminder Threshold',
          controller: thresholdController,
          errorText: errors['reminderThreshold'],
          keyboardType: TextInputType.number,
        ),
      ],
    ],
  );
}
