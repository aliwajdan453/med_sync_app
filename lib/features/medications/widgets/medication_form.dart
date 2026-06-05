import 'package:flutter/material.dart';
import 'package:med_sync/core/widgets/app_error_banner.dart';
import 'package:med_sync/features/medications/models/medication.dart';
import 'package:med_sync/features/medications/models/medication_form_state.dart';
import 'package:med_sync/features/medications/widgets/medication_dose_fields.dart';
import 'package:med_sync/features/medications/widgets/medication_refill_fields.dart';
import 'package:med_sync/features/medications/widgets/medication_schedule_fields.dart';

class MedicationForm extends StatefulWidget {
  const MedicationForm({
    required this.state,
    required this.onSubmit,
    this.initialMedication,
    super.key,
  });

  final MedicationFormState state;
  final Medication? initialMedication;
  final ValueChanged<MedicationFormInput> onSubmit;

  @override
  State<MedicationForm> createState() => _MedicationFormState();
}

class _MedicationFormState extends State<MedicationForm> {
  late final TextEditingController _nameController;
  late final TextEditingController _doseAmountController;
  late final TextEditingController _customDoseUnitController;
  late final TextEditingController _instructionsController;
  late final TextEditingController _currentQuantityController;
  late final TextEditingController _doseQuantityController;
  late final TextEditingController _thresholdController;
  var _category = MedicationCategory.prescription;
  var _routineType = MedicationRoutineType.scheduled;
  var _doseUnit = 'mg';
  var _schedulePattern = MedicationSchedulePattern.daily;
  var _weekdays = <int>{};
  var _time = const MedicationTime(hour: 8, minute: 0);
  var _refillEnabled = false;

  @override
  void initState() {
    super.initState();
    final medication = widget.initialMedication;
    _nameController = TextEditingController(text: medication?.name ?? '');
    _doseAmountController = TextEditingController(
      text: medication == null ? '' : _formatNumber(medication.doseAmount),
    );
    _customDoseUnitController = TextEditingController(
      text: _customUnitFor(medication),
    );
    _instructionsController = TextEditingController(
      text: medication?.instructions ?? '',
    );
    _currentQuantityController = TextEditingController(
      text: _refillText(medication, (info) => info.currentQuantity),
    );
    _doseQuantityController = TextEditingController(
      text: _refillText(medication, (info) => info.doseQuantity),
    );
    _thresholdController = TextEditingController(
      text: _refillText(medication, (info) => info.reminderThreshold),
    );
    if (medication != null) {
      _category = medication.category;
      _routineType = medication.routineType;
      _doseUnit = doseUnitOptions.contains(medication.doseUnit)
          ? medication.doseUnit
          : 'custom';
      _schedulePattern =
          medication.schedule?.pattern ?? MedicationSchedulePattern.daily;
      _weekdays = medication.schedule?.weekdays.toSet() ?? <int>{};
      final times = medication.schedule?.times ?? const <MedicationTime>[];
      _time = times.isEmpty ? _time : times.first;
      _refillEnabled = medication.refillInfo != null;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _doseAmountController.dispose();
    _customDoseUnitController.dispose();
    _instructionsController.dispose();
    _currentQuantityController.dispose();
    _doseQuantityController.dispose();
    _thresholdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final errors = widget.state.fieldErrors;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        AppErrorBanner(
          message: widget.state.failure?.description,
          diagnosticCode: widget.state.failure?.diagnosticCode,
          diagnosticMessage: widget.state.failure?.diagnosticMessage,
          stackTrace: widget.state.failure?.stackTrace,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Medication Name',
            errorText: errors['name'],
          ),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<MedicationCategory>(
          initialValue: _category,
          decoration: const InputDecoration(labelText: 'Category'),
          items: const [
            DropdownMenuItem(
              value: MedicationCategory.prescription,
              child: Text('Prescription'),
            ),
            DropdownMenuItem(value: MedicationCategory.otc, child: Text('OTC')),
            DropdownMenuItem(
              value: MedicationCategory.supplement,
              child: Text('Supplement'),
            ),
          ],
          onChanged: (value) => setState(() => _category = value ?? _category),
        ),
        const SizedBox(height: 16),
        SegmentedButton<MedicationRoutineType>(
          segments: const [
            ButtonSegment(
              value: MedicationRoutineType.scheduled,
              label: Text('Scheduled'),
            ),
            ButtonSegment(
              value: MedicationRoutineType.asNeeded,
              label: Text('As needed'),
            ),
          ],
          selected: {_routineType},
          onSelectionChanged: (selection) =>
              setState(() => _routineType = selection.single),
        ),
        const SizedBox(height: 16),
        MedicationDoseFields(
          doseAmountController: _doseAmountController,
          customDoseUnitController: _customDoseUnitController,
          doseUnit: _doseUnit,
          errors: errors,
          onDoseUnitChanged: (value) => setState(() => _doseUnit = value),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _instructionsController,
          decoration: InputDecoration(
            labelText: 'Routine Instructions',
            errorText: errors['instructions'],
          ),
          minLines: 2,
          maxLines: 4,
        ),
        if (_routineType == MedicationRoutineType.scheduled) ...[
          const SizedBox(height: 24),
          MedicationScheduleFields(
            pattern: _schedulePattern,
            weekdays: _weekdays,
            time: _time,
            errors: errors,
            onPatternChanged: (value) =>
                setState(() => _schedulePattern = value),
            onWeekdaysChanged: (value) => setState(() => _weekdays = value),
            onTimeChanged: (value) => setState(() => _time = value),
          ),
        ],
        const SizedBox(height: 24),
        MedicationRefillFields(
          enabled: _refillEnabled,
          currentQuantityController: _currentQuantityController,
          doseQuantityController: _doseQuantityController,
          thresholdController: _thresholdController,
          errors: errors,
          onEnabledChanged: (value) => setState(() => _refillEnabled = value),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: widget.state.isSubmitting ? null : _submit,
          child: Text(
            widget.state.isSubmitting ? 'Saving...' : 'Save medication',
          ),
        ),
      ],
    );
  }

  void _submit() {
    final refillInfo = _refillEnabled
        ? RefillInfo(
            currentQuantity: _parseNumber(_currentQuantityController.text) ?? 0,
            doseQuantity: _parseNumber(_doseQuantityController.text) ?? 0,
            reminderThreshold: _parseNumber(_thresholdController.text) ?? 0,
          )
        : null;

    widget.onSubmit(
      MedicationFormInput(
        name: _nameController.text,
        category: _category,
        routineType: _routineType,
        doseAmount: _parseNumber(_doseAmountController.text),
        doseUnit: _doseUnit,
        customDoseUnit: _customDoseUnitController.text,
        instructions: _instructionsController.text,
        schedule: _routineType == MedicationRoutineType.scheduled
            ? MedicationSchedule(
                pattern: _schedulePattern,
                weekdays: _schedulePattern == MedicationSchedulePattern.weekdays
                    ? (_weekdays.toList()..sort())
                    : const <int>[],
                times: <MedicationTime>[_time],
              )
            : null,
        refillInfo: refillInfo,
      ),
    );
  }
}

double? _parseNumber(String value) => double.tryParse(value.trim());

String _formatNumber(double value) {
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  }
  return value.toString();
}

String _refillText(Medication? medication, double Function(RefillInfo) select) {
  final refillInfo = medication?.refillInfo;
  return refillInfo == null ? '' : _formatNumber(select(refillInfo));
}

String _customUnitFor(Medication? medication) {
  final unit = medication?.doseUnit;
  if (unit == null || doseUnitOptions.contains(unit)) {
    return '';
  }
  return unit;
}
