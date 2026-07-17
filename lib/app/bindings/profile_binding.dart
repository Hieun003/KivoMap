import 'package:get/get.dart';

import '../../data/energy_service.dart';
import '../../data/user_profile_service.dart';
import '../../data/vocabulary_learning_service.dart';
import '../../features/profile/view_model/profile_view_model.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<EnergyService>()) {
      Get.put(EnergyService(), permanent: true);
    }
    if (!Get.isRegistered<VocabularyLearningService>()) {
      Get.put(VocabularyLearningService(), permanent: true);
    }
    if (!Get.isRegistered<UserProfileService>()) {
      Get.put(UserProfileService(), permanent: true);
    }
    if (!Get.isRegistered<ProfileViewModel>()) {
      Get.put(ProfileViewModel());
    }
  }
}
