import 'package:get/get.dart';

import '../../data/vocabulary_learning_service.dart';
import '../../features/treasure/view_model/treasure_view_model.dart';

class TreasureBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<VocabularyLearningService>()) {
      Get.put(VocabularyLearningService(), permanent: true);
    }
    if (!Get.isRegistered<TreasureViewModel>()) {
      Get.put(TreasureViewModel());
    }
  }
}
