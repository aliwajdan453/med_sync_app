import 'package:flutter/material.dart';
import 'package:med_sync/core/design_system/base_app_bar.dart';
import 'package:med_sync/core/design_system/base_scaffold.dart';
import 'package:med_sync/core/theme/app_colors.dart';

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    required this.title,
    required this.children,
    super.key,
    this.subtitle,
    this.showBackButton = true,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BaseScaffold(
      appBar: BaseAppBar(title: '', showLeading: showBackButton),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
        children: [
          Text(
            title,
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8.0),
            Text(
              subtitle!,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyLarge?.copyWith(
                color: AppColors.slateLabel,
                height: 1.45,
              ),
            ),
          ],
          const SizedBox(height: 24.0),
          ...children,
        ],
      ),
    );
  }
}
