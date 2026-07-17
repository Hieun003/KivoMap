import 'package:get/get.dart';

import '../../data/vocabulary_learning_service.dart';
import '../../features/vocabulary_profile/view_model/vocabulary_profile_view_model.dart';

class VocabularyProfileBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<VocabularyLearningService>()) {
      Get.put(VocabularyLearningService(), permanent: true);
    }
    Get.lazyPut<VocabularyProfileViewModel>(() => VocabularyProfileViewModel());
  }
}
