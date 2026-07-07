import 'package:get/get.dart';

import '../../data/vocabulary_learning_service.dart';
import '../../features/discovery/view_model/discovery_view_model.dart';

class DiscoveryBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<VocabularyLearningService>()) {
      Get.put(VocabularyLearningService(), permanent: true);
    }
    Get.lazyPut<DiscoveryViewModel>(() => DiscoveryViewModel());
  }
}
