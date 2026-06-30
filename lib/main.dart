import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app/navigation/main_navigation_shell.dart';
import 'app/theme/kivo_theme.dart';

import 'data/database_engine_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final dbEngine = DatabaseEngineService();
  await dbEngine.seedStaticKnowledgeBase();
  await dbEngine.activateUserRuntimeEnvironment(
    userId: 'test_user_id_123',
    name: 'KivoMap Developer',
    email: 'dev.kivomap@gmail.com',
  );
  await dbEngine.bootstrapFirestoreSchema(userId: 'test_user_id_123');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KivoMap Language',
      theme: KivoTheme.light,
      home: const MainNavigationShell(),
    );
  }
}
