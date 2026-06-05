import 'package:flutter/material.dart';

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
        TextField(
          controller: currentQuantityController,
          decoration: InputDecoration(
            labelText: 'Remaining Supply',
            errorText: errors['currentQuantity'],
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: doseQuantityController,
          decoration: InputDecoration(
            labelText: 'Dose Quantity',
            errorText: errors['doseQuantity'],
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: thresholdController,
          decoration: InputDecoration(
            labelText: 'Reminder Threshold',
            errorText: errors['reminderThreshold'],
          ),
          keyboardType: TextInputType.number,
        ),
      ],
    ],
  );
}
