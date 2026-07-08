import 'package:get/get.dart';

import '../../data/energy_service.dart';
import '../../data/vocabulary_learning_service.dart';
import '../../features/review/view_model/review_view_model.dart';

class ReviewBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<EnergyService>()) {
      Get.put(EnergyService(), permanent: true);
    }
    if (!Get.isRegistered<VocabularyLearningService>()) {
      Get.put(VocabularyLearningService(), permanent: true);
    }
    Get.lazyPut<ReviewViewModel>(() => ReviewViewModel());
  }
}
