import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:med_sync/app/app_session.dart';
import 'package:med_sync/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MedSyncRoot());
}
