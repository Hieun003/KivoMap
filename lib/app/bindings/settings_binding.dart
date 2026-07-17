import 'package:get/get.dart';

import '../../data/app_preferences_service.dart';
import '../../data/user_profile_service.dart';
import '../../features/settings/view_model/settings_view_model.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AppPreferencesService>()) {
      Get.put(AppPreferencesService(), permanent: true);
    }
    if (!Get.isRegistered<UserProfileService>()) {
      Get.put(UserProfileService(), permanent: true);
    }
    if (!Get.isRegistered<SettingsViewModel>()) {
      Get.put(SettingsViewModel());
    }
  }
}
