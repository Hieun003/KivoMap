import 'package:get/get.dart';

import 'vocabulary_planet_view_state.dart';

class VocabularyPlanetViewModel extends GetxController {
  final RxBool isLoading = true.obs;
  final RxnString errorMessage = RxnString();
  final Rxn<VocabularyPlanetState> state = Rxn<VocabularyPlanetState>();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final args = Get.arguments;
      final clusterId = args is Map ? args['clusterId'] as String? : null;
      state.value = _sampleStateFor(clusterId);
    } catch (_) {
      errorMessage.value = 'Không thể mở hành tinh từ vựng. Hãy thử lại nhé.';
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Future<void> refresh() => load();

  void goBack() {
    Get.back<void>();
  }

  void selectNode(VocabularyPlanetNodeData node) {
    if (node.status == VocabularyNodeStatus.locked) {
      Get.snackbar(
        'Chưa mở khóa',
        'Hoàn thành các từ trước để mở ${node.label.replaceAll('\n', ' ')} nhé.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(milliseconds: 1400),
      );
      return;
    }

    Get.snackbar(
      'Sẵn sàng khám phá',
      '${node.label.replaceAll('\n', ' ')} sẽ mở Discover Matrix ở bước tiếp theo.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(milliseconds: 1400),
    );
  }

  VocabularyPlanetState _sampleStateFor(String? clusterId) {
    return switch (clusterId) {
      'cluster_airport_checkin' || null => VocabularyPlanetState.airportCheckIn,
      _ => VocabularyPlanetState.airportCheckIn,
    };
  }
}
