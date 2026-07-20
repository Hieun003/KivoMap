import 'package:get/get.dart';

import '../../data/energy_service.dart';
import '../../data/vocabulary_learning_service.dart';
import '../../features/home/view_model/home_view_model.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<EnergyService>()) {
      Get.put(EnergyService(), permanent: true);
    }
    if (!Get.isRegistered<VocabularyLearningService>()) {
      Get.put(VocabularyLearningService(), permanent: true);
    }
    if (!Get.isRegistered<HomeViewModel>()) {
      Get.lazyPut<HomeViewModel>(() => HomeViewModel());
    }
  }
}
