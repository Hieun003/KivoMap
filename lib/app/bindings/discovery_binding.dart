import 'package:get/get.dart';

import '../../features/discovery/view_model/discovery_view_model.dart';

class DiscoveryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DiscoveryViewModel>(() => DiscoveryViewModel());
  }
}
