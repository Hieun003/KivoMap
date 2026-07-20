import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../data/app_preferences_service.dart';
import '../../../data/user_profile_service.dart';
import '../../auth/view_model/auth_controller.dart';

class SettingsViewModel extends GetxController {
  SettingsViewModel({
    AppPreferencesService? preferencesService,
    UserProfileService? profileService,
    AuthController? authController,
  }) : _preferencesService =
           preferencesService ?? Get.find<AppPreferencesService>(),
       _profileService = profileService ?? Get.find<UserProfileService>(),
       _authController =
           authController ??
           (Get.isRegistered<AuthController>()
               ? Get.find<AuthController>()
               : null);

  final AppPreferencesService _preferencesService;
  final UserProfileService _profileService;
  final AuthController? _authController;

  final RxBool isLoading = true.obs;
  final RxBool isSigningOut = false.obs;
  RxBool get audioEnabled => _preferencesService.audioEnabled;
  Rx<UserProfileData> get profile => _profileService.profile;
  bool get canSignOut => _authController != null;

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

  Future<void> signOut() async {
    final authController = _authController;
    if (authController == null || isSigningOut.value) return;
    isSigningOut.value = true;
    try {
      await authController.signOut();
    } finally {
      isSigningOut.value = false;
    }
  }
}
