import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_sync/core/design_system/base_app_bar.dart';
import 'package:med_sync/core/design_system/base_scaffold.dart';
import 'package:med_sync/core/navigation/app_navigator.dart';
import 'package:med_sync/features/auth/views/profile_view.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const routeName = 'settings';
  static const routePath = '/settings';

  @override
  Widget build(BuildContext context, WidgetRef ref) => BaseScaffold(
    appBar: const BaseAppBar(title: 'Settings', showLeading: false),
    child: ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.person_outline),
          title: const Text('Profile'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () =>
              ref.read(appNavigatorProvider).push(ProfileView.routePath),
        ),
      ],
    ),
  );
}
