import 'package:get/get.dart';

import 'home_view_state.dart';

class HomeViewModel extends GetxController {
  final RxBool isLoading = true.obs;
  final RxnString errorMessage = RxnString();
  final Rxn<HomeDashboardState> state = Rxn<HomeDashboardState>();

  HomeDashboardState? _sourceState;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      _sourceState = HomeDashboardState.sampleReviewDue;
      state.value = _buildFilteredState(selectedCategoryKey: 'default');
    } catch (_) {
      errorMessage.value = 'Không thể tải trang chủ. Hãy thử lại nhé.';
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Future<void> refresh() => load();

  void selectCategory(HomeCategoryChipData category) {
    final selectedKey = _normalizeKey(category.iconKey);
    state.value = _buildFilteredState(selectedCategoryKey: selectedKey);
  }

  void startLearning() {
    // Route target will be connected when Cluster Learning is implemented.
  }

  void startReview() {
    // Route target will be connected when Review Queue is implemented.
  }

  HomeDashboardState? _buildFilteredState({
    required String selectedCategoryKey,
  }) {
    final source = _sourceState;
    if (source == null) {
      return null;
    }

    final normalizedSelectedKey = _normalizeKey(selectedCategoryKey);
    final categories = source.categories
        .map((category) {
          return category.copyWith(
            isSelected:
                _normalizeKey(category.iconKey) == normalizedSelectedKey,
          );
        })
        .toList(growable: false);

    if (normalizedSelectedKey == 'default') {
      return source.copyWith(categories: categories);
    }

    final filteredSections = <HomeContextSectionData>[];
    for (final section in source.contextSections) {
      final sectionKey = _normalizeKey(section.iconKey);
      if (_keysMatch(sectionKey, normalizedSelectedKey)) {
        filteredSections.add(section);
        continue;
      }

      final matchingItems = section.items
          .where((item) {
            return _keysMatch(
              _normalizeKey(item.iconKey),
              normalizedSelectedKey,
            );
          })
          .toList(growable: false);

      if (matchingItems.isNotEmpty) {
        filteredSections.add(section.copyWith(items: matchingItems));
      }
    }

    return source.copyWith(
      categories: categories,
      contextSections: filteredSections,
    );
  }

  static bool _keysMatch(String candidateKey, String selectedKey) {
    if (candidateKey == selectedKey) {
      return true;
    }

    return switch (selectedKey) {
      'airport' =>
        candidateKey == 'airport_check_in' || candidateKey == 'travel',
      'restaurant' => candidateKey == 'ordering_food',
      'shopping' => candidateKey == 'shopping',
      'office' => candidateKey == 'work',
      _ => false,
    };
  }

  static String _normalizeKey(String key) {
    return key.trim().toLowerCase().replaceAll(RegExp(r'[\s-]+'), '_');
  }
}
