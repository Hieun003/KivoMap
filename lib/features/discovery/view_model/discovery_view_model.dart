import 'package:get/get.dart';

import 'discovery_view_state.dart';

class DiscoveryViewModel extends GetxController {
  final RxBool isLoading = true.obs;
  final RxnString errorMessage = RxnString();
  final Rxn<DiscoveryMatrixState> state = Rxn<DiscoveryMatrixState>();
  final RxnString selectedContextId = RxnString();

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
      final vocabularyId = args is Map ? args['vocabularyId'] as String? : null;
      state.value = _sampleStateFor(vocabularyId);
      selectedContextId.value = state.value?.activeContext?.id;
    } catch (_) {
      errorMessage.value = 'Không thể mở Ma trận Khám phá. Hãy thử lại nhé.';
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Future<void> refresh() => load();

  void goBack() {
    Get.back<void>();
  }

  bool selectContext(DiscoveryContextNode context) {
    if (!context.isUnlocked) {
      Get.snackbar(
        'Chưa mở ngữ cảnh',
        'Khám phá các ngữ cảnh trước để mở ${context.title}.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(milliseconds: 1500),
      );
      return false;
    }

    selectedContextId.value = context.id;
    return true;
  }

  DiscoveryMatrixState _sampleStateFor(String? vocabularyId) {
    return switch (vocabularyId) {
      'vocab_passport' || null => DiscoveryMatrixState.passportDemo,
      _ => DiscoveryMatrixState.passportDemo,
    };
  }
}
