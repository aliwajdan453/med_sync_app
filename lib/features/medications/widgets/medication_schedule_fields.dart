import 'package:flutter/material.dart';
import 'package:med_sync/features/medications/models/medication.dart';

class MedicationScheduleFields extends StatelessWidget {
  const MedicationScheduleFields({
    required this.pattern,
    required this.weekdays,
    required this.time,
    required this.errors,
    required this.onPatternChanged,
    required this.onWeekdaysChanged,
    required this.onTimeChanged,
    super.key,
  });

  final MedicationSchedulePattern pattern;
  final Set<int> weekdays;
  final MedicationTime time;
  final Map<String, String> errors;
  final ValueChanged<MedicationSchedulePattern> onPatternChanged;
  final ValueChanged<Set<int>> onWeekdaysChanged;
  final ValueChanged<MedicationTime> onTimeChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Schedule',
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 12),
      SegmentedButton<MedicationSchedulePattern>(
        segments: const [
          ButtonSegment(
            value: MedicationSchedulePattern.daily,
            label: Text('Daily'),
          ),
          ButtonSegment(
            value: MedicationSchedulePattern.weekdays,
            label: Text('Weekdays'),
          ),
        ],
        selected: {pattern},
        onSelectionChanged: (selection) => onPatternChanged(selection.single),
      ),
      if (pattern == MedicationSchedulePattern.weekdays) ...[
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: List<Widget>.generate(7, (index) {
            final day = index + 1;
            return FilterChip(
              label: Text(_weekdayLabel(day)),
              selected: weekdays.contains(day),
              onSelected: (selected) {
                final next = {...weekdays};
                if (selected) {
                  next.add(day);
                } else {
                  next.remove(day);
                }
                onWeekdaysChanged(next);
              },
            );
          }),
        ),
        if (errors['weekdays'] != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              errors['weekdays']!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
      ],
      const SizedBox(height: 12),
      ListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('Scheduled Time'),
        subtitle: Text(time.label),
        trailing: const Icon(Icons.schedule),
        onTap: () => _pickTime(context),
      ),
      if (errors['schedule'] != null)
        Text(
          errors['schedule']!,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
    ],
  );

  Future<void> _pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: time.hour, minute: time.minute),
    );
    if (picked != null) {
      onTimeChanged(MedicationTime(hour: picked.hour, minute: picked.minute));
    }
  }
}

String _weekdayLabel(int weekday) => switch (weekday) {
  1 => 'Mon',
  2 => 'Tue',
  3 => 'Wed',
  4 => 'Thu',
  5 => 'Fri',
  6 => 'Sat',
  7 => 'Sun',
  _ => '',
};
