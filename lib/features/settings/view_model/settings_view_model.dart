import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../data/app_preferences_service.dart';
import '../../../data/user_profile_service.dart';

class SettingsViewModel extends GetxController {
  SettingsViewModel({
    AppPreferencesService? preferencesService,
    UserProfileService? profileService,
  }) : _preferencesService =
           preferencesService ?? Get.find<AppPreferencesService>(),
       _profileService = profileService ?? Get.find<UserProfileService>();

  final AppPreferencesService _preferencesService;
  final UserProfileService _profileService;
  final RxBool isLoading = true.obs;
  RxBool get audioEnabled => _preferencesService.audioEnabled;
  Rx<UserProfileData> get profile => _profileService.profile;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    await _preferencesService.initialize();
    await _profileService.initialize();
    isLoading.value = false;
  }

  Future<void> setAudioEnabled(bool value) =>
      _preferencesService.setAudioEnabled(value);
  void openPersonalProfile() => Get.toNamed<void>(AppRoutes.personalProfile);
}
