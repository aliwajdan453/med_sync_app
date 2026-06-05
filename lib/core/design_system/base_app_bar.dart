import 'package:flutter/material.dart';

class BaseAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BaseAppBar({
    required this.title,
    super.key,
    this.leading,
    this.trailing,
    this.showLeading = true,
  });

  final String title;
  final Widget? leading;
  final Widget? trailing;
  final bool showLeading;

  @override
  Widget build(BuildContext context) => AppBar(
    title: Text(title),
    leading: showLeading ? leading : const SizedBox.shrink(),
    automaticallyImplyLeading: showLeading && leading == null,
    actions: trailing != null ? [trailing!] : null,
  );

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
