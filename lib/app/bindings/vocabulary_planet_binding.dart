import 'package:get/get.dart';

import '../../data/vocabulary_learning_service.dart';
import '../../features/cluster_learning/view_model/vocabulary_planet_view_model.dart';

class VocabularyPlanetBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<VocabularyLearningService>()) {
      Get.put(VocabularyLearningService(), permanent: true);
    }
    Get.lazyPut<VocabularyPlanetViewModel>(() => VocabularyPlanetViewModel());
  }
}
