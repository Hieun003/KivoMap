import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/assets/image_paths.dart';
import '../../../app/navigation/main_navigation_shell.dart';
import '../../../app/theme/kivo_theme_tokens.dart';
import '../view_model/auth_controller.dart';
import 'auth_entry_view.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key, this.startupError});

  final Object? startupError;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<AuthController>()) {
      if (startupError != null) return const _AuthUnavailableView();
      return const MainNavigationShell();
    }
    final controller = Get.find<AuthController>();
    return Obx(() {
      if (!controller.isReady.value) return const _AuthLoadingView();
      if (controller.user.value == null) return const AuthEntryView();
      return const MainNavigationShell();
    });
  }
}

class _AuthUnavailableView extends StatelessWidget {
  const _AuthUnavailableView();

  @override
  Widget build(BuildContext context) => const Scaffold(
    backgroundColor: KivoColors.cream,
    body: SafeArea(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image(
                image: AssetImage(KivoImagePaths.kivoChallengeFail),
                width: 170,
                height: 170,
              ),
              SizedBox(height: 20),
              Text(
                'Không thể kết nối Kivo',
                textAlign: TextAlign.center,
                style: KivoTextStyles.sectionTitle,
              ),
              SizedBox(height: 10),
              Text(
                'Hãy kiểm tra kết nối mạng rồi mở lại ứng dụng.',
                textAlign: TextAlign.center,
                style: KivoTextStyles.body,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _AuthLoadingView extends StatelessWidget {
  const _AuthLoadingView();

  @override
  Widget build(BuildContext context) => const Scaffold(
    backgroundColor: KivoColors.cream,
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image(
            image: AssetImage(KivoImagePaths.kivoLogin),
            width: 150,
            height: 150,
          ),
          SizedBox(height: 20),
          CircularProgressIndicator(color: KivoColors.kivoTeal),
        ],
      ),
    ),
  );
}
