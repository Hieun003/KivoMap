import 'package:get/get.dart';

import '../../features/cluster_learning/view_model/vocabulary_planet_view_model.dart';

class VocabularyPlanetBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VocabularyPlanetViewModel>(() => VocabularyPlanetViewModel());
  }
}
