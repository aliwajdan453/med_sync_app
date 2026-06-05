import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_sync/app/med_sync_app.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part '../generated/app/app_session.g.dart';

@riverpod
VoidCallback sessionResetter(Ref ref) => () {};

class MedSyncRoot extends StatefulWidget {
  const MedSyncRoot({super.key});

  @override
  State<MedSyncRoot> createState() => _MedSyncRootState();
}

class _MedSyncRootState extends State<MedSyncRoot> {
  var _sessionKey = 0;

  void _resetSession() {
    setState(() {
      _sessionKey += 1;
    });
  }

  @override
  Widget build(BuildContext context) => ProviderScope(
    key: ValueKey(_sessionKey),
    overrides: [sessionResetterProvider.overrideWithValue(_resetSession)],
    child: const MedSyncApp(),
  );
}
