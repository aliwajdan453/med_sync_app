import 'package:flutter/material.dart';
import 'package:med_sync/core/design_system/base_app_bar.dart';
import 'package:med_sync/core/design_system/base_scaffold.dart';
import 'package:med_sync/core/theme/app_colors.dart';

class MissedDoseScreen extends StatelessWidget {
  const MissedDoseScreen({super.key});

  static const routeName = 'missed-doses';
  static const routePath = '/missed-doses';

  @override
  Widget build(BuildContext context) => BaseScaffold(
    appBar: const BaseAppBar(title: 'Missed Dose Review'),
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ExcludeSemantics(
              child: Icon(
                Icons.event_available_outlined,
                size: 44.0,
                color: AppColors.dataTeal,
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              'No missed doses to review',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Missed dose review will appear after scheduled dose tracking is implemented.',
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.slateLabel),
            ),
          ],
        ),
      ),
    ),
  );
}
