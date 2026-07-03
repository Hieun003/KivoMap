import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'app/bindings/home_binding.dart';
import 'app/bindings/discovery_binding.dart';
import 'app/bindings/vocabulary_planet_binding.dart';
import 'app/navigation/main_navigation_shell.dart';
import 'app/responsive/kivo_scale.dart';
import 'app/routes/app_routes.dart';
import 'app/theme/kivo_theme.dart';
import 'features/cluster_learning/view/vocabulary_planet_view.dart';
import 'features/discovery/view/discovery_matrix_view.dart';

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
    return ScreenUtilInit(
      designSize: KivoScale.designSize,
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'KivoMap Language',
          theme: KivoTheme.light,
          initialRoute: AppRoutes.home,
          debugShowCheckedModeBanner: false,
          getPages: [
            GetPage(
              name: AppRoutes.home,
              page: () => const MainNavigationShell(),
              binding: HomeBinding(),
            ),
            GetPage(
              name: AppRoutes.vocabularyPlanet,
              page: () => const VocabularyPlanetView(),
              binding: VocabularyPlanetBinding(),
            ),
            GetPage(
              name: AppRoutes.discoveryMatrix,
              page: () => const DiscoveryMatrixView(),
              binding: DiscoveryBinding(),
            ),
          ],
        );
      },
    );
  }
}
