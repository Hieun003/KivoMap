import 'dart:developer' as developer;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'app/bindings/auth_binding.dart';
import 'app/bindings/home_binding.dart';
import 'app/bindings/review_binding.dart';
import 'app/bindings/settings_binding.dart';
import 'app/bindings/discovery_binding.dart';
import 'app/bindings/vocabulary_planet_binding.dart';
import 'app/bindings/vocabulary_profile_binding.dart';
import 'app/navigation/main_navigation_shell.dart';
import 'app/responsive/kivo_scale.dart';
import 'app/routes/app_routes.dart';
import 'app/theme/kivo_theme.dart';
import 'features/cluster_learning/view/vocabulary_planet_view.dart';
import 'features/auth/view/auth_gate.dart';
import 'features/auth/view/otp_verification_view.dart';
import 'features/auth/view/phone_auth_view.dart';
import 'features/vocabulary_profile/view/vocabulary_profile_view.dart';
import 'features/discovery/view/discovery_matrix_view.dart';
import 'features/review/view/review_view.dart';
import 'features/passageway/view/passageway_cave_list_view.dart';
import 'features/secret_passage/view/secret_passage_intro_view.dart';
import 'features/settings/view/settings_view.dart';
import 'features/settings/view/personal_profile_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Object? startupError;
  try {
    await Firebase.initializeApp();
    AuthBinding().dependencies();
  } catch (error, stackTrace) {
    startupError = error;
    developer.log(
      'Firebase initialization failed.',
      name: 'KivoMap',
      error: error,
      stackTrace: stackTrace,
    );
  }
  runApp(MyApp(startupError: startupError));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.startupError});

  final Object? startupError;

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
          initialRoute: AppRoutes.root,
          debugShowCheckedModeBanner: false,
          getPages: [
            GetPage(
              name: AppRoutes.root,
              page: () => AuthGate(startupError: startupError),
            ),
            GetPage(
              name: AppRoutes.home,
              page: () => const MainNavigationShell(),
              binding: HomeBinding(),
            ),
            GetPage(
              name: AppRoutes.authPhone,
              page: () => const PhoneAuthView(),
            ),
            GetPage(
              name: AppRoutes.authOtp,
              page: () => const OtpVerificationView(),
            ),
            GetPage(
              name: AppRoutes.treasure,
              page: () => const MainNavigationShell(initialIndex: 1),
              binding: HomeBinding(),
            ),
            GetPage(
              name: AppRoutes.profile,
              page: () => const MainNavigationShell(initialIndex: 2),
              binding: HomeBinding(),
            ),
            GetPage(
              name: AppRoutes.settings,
              page: () => const SettingsView(),
              binding: SettingsBinding(),
            ),
            GetPage(
              name: AppRoutes.personalProfile,
              page: () => const PersonalProfileView(),
              binding: SettingsBinding(),
            ),
            GetPage(
              name: AppRoutes.vocabularyPlanet,
              page: () => const VocabularyPlanetView(),
              binding: VocabularyPlanetBinding(),
            ),
            GetPage(
              name: AppRoutes.vocabularyProfile,
              page: () => const VocabularyProfileView(),
              binding: VocabularyProfileBinding(),
            ),
            GetPage(
              name: AppRoutes.discoveryMatrix,
              page: () => const DiscoveryMatrixView(),
              binding: DiscoveryBinding(),
            ),
            GetPage(
              name: AppRoutes.review,
              page: () => const ReviewView(),
              binding: ReviewBinding(),
            ),
            GetPage(
              name: AppRoutes.secretPassage,
              page: () => const SecretPassageIntroView(),
            ),
            GetPage(
              name: AppRoutes.passageway,
              page: () => const PassagewayCaveListView(),
            ),
          ],
        );
      },
    );
  }
}
