import 'package:flutter/material.dart';
import 'package:med_sync/core/design_system/base_scaffold.dart';
import 'package:med_sync/core/theme/app_colors.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  static const routeName = 'splash';
  static const routePath = '/splash';

  @override
  Widget build(BuildContext context) => BaseScaffold(
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ExcludeSemantics(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: const Padding(
                padding: EdgeInsets.all(22.0),
                child: Icon(
                  Icons.medication_liquid_outlined,
                  color: AppColors.primary,
                  size: 44.0,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18.0),
          Text(
            'MedSync',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 24.0),
          const CircularProgressIndicator.adaptive(),
        ],
      ),
    ),
  );
}
