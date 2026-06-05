import 'package:flutter/material.dart';
import 'package:med_sync/core/widgets/app_text_field.dart';
import 'package:med_sync/features/medications/models/medication.dart';

class MedicationDoseFields extends StatelessWidget {
  const MedicationDoseFields({
    required this.doseAmountController,
    required this.customDoseUnitController,
    required this.doseUnit,
    required this.errors,
    required this.onDoseUnitChanged,
    super.key,
  });

  final TextEditingController doseAmountController;
  final TextEditingController customDoseUnitController;
  final String doseUnit;
  final Map<String, String> errors;
  final ValueChanged<String> onDoseUnitChanged;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Row(
        children: [
          Expanded(
            child: AppTextField(
              label: 'Dose Amount',
              controller: doseAmountController,
              errorText: errors['doseAmount'],
              keyboardType: TextInputType.number,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: doseUnit,
              decoration: InputDecoration(
                labelText: 'Unit',
                errorText: errors['doseUnit'],
              ),
              items: doseUnitOptions
                  .map(
                    (unit) => DropdownMenuItem(
                      value: unit,
                      child: Text(unit == 'custom' ? 'Custom' : unit),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (value) => onDoseUnitChanged(value ?? doseUnit),
            ),
          ),
        ],
      ),
      if (doseUnit == 'custom') ...[
        const SizedBox(height: 16),
        AppTextField(
          label: 'Custom unit',
          controller: customDoseUnitController,
          errorText: errors['doseUnit'],
        ),
      ],
    ],
  );
}
