import 'package:get/get.dart';

import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/data/firebase_auth_repository.dart';
import '../../features/auth/view_model/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthRepository>()) {
      Get.put<AuthRepository>(FirebaseAuthRepository(), permanent: true);
    }
    if (!Get.isRegistered<AuthController>()) {
      Get.put(
        AuthController(repository: Get.find<AuthRepository>()),
        permanent: true,
      );
    }
  }
}
