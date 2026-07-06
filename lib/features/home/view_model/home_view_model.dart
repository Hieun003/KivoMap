import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../data/kivo_seed_data.dart';
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
      _sourceState = _buildStateFromSeed();
      state.value = _buildFilteredState(selectedCategoryKey: 'default');
    } catch (_) {
      errorMessage.value =
          'Kh\u00f4ng th\u1ec3 t\u1ea3i trang ch\u1ee7. H\u00e3y th\u1eed l\u1ea1i nh\u00e9.';
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
    final firstTopic = _sourceState?.contextSections
        .expand((section) => section.items)
        .firstOrNull;
    if (firstTopic != null) {
      openTopic(firstTopic);
    }
  }

  void startReview() {
    // Review queue will consume seeded review state when that feature is wired.
  }

  void openTopic(HomeContextTopicData topic) {
    Get.toNamed(
      AppRoutes.vocabularyPlanet,
      arguments: {
        'clusterId': topic.clusterId,
        'title': topic.title,
        'subtitle': topic.subtitle,
        'iconKey': topic.iconKey,
      },
    );
  }

  HomeDashboardState _buildStateFromSeed() {
    final sectionsByCategory = <String, List<HomeContextTopicData>>{};

    for (
      var clusterIndex = 0;
      clusterIndex < seedClusters.length;
      clusterIndex++
    ) {
      final cluster = seedClusters[clusterIndex];
      final clusterId = _stringValue(cluster, 'id');
      final category = _stringValue(cluster, 'category', fallback: 'DAILY');
      final vocabCount = seedVocabularies
          .where(
            (vocabulary) => _stringValue(vocabulary, 'clusterId') == clusterId,
          )
          .length;
      final totalCount = vocabCount == 0 ? 1 : vocabCount;
      final learnedCount = totalCount <= 1 ? 0 : totalCount.clamp(0, 2);
      final accent = _accentForIndex(clusterIndex);

      sectionsByCategory
          .putIfAbsent(category, () => <HomeContextTopicData>[])
          .add(
            HomeContextTopicData(
              clusterId: clusterId,
              title: _stringValue(
                cluster,
                'titleVi',
                fallback: _stringValue(cluster, 'title'),
              ),
              subtitle: '(${_stringValue(cluster, 'title')})',
              iconKey: _stringValue(cluster, 'iconKey', fallback: 'default'),
              learnedCount: learnedCount,
              totalCount: totalCount,
              accentColor: accent,
            ),
          );
    }

    final categories = <HomeCategoryChipData>[
      const HomeCategoryChipData(
        label: 'T\u1ea5t c\u1ea3',
        iconKey: 'default',
        isSelected: true,
      ),
      for (final category in sectionsByCategory.keys)
        HomeCategoryChipData(
          label: _categoryLabel(category),
          iconKey: _categoryIconKey(category),
        ),
    ];

    final sections = <HomeContextSectionData>[
      for (final entry in sectionsByCategory.entries)
        HomeContextSectionData(
          title: _categoryLabel(entry.key),
          iconKey: _categoryIconKey(entry.key),
          accentColor: _categoryAccent(entry.key),
          items: entry.value,
        ),
    ];

    return HomeDashboardState(
      userName: 'Explorer',
      roleLabel: 'Explorer',
      energy: 24,
      maxEnergy: 50,
      streakDays: 7,
      bannerStatus: HomeReviewBannerStatus.reviewDue,
      categories: categories,
      contextSections: sections,
    );
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

    final filteredSections = source.contextSections
        .where((section) {
          return _normalizeKey(section.iconKey) == normalizedSelectedKey;
        })
        .toList(growable: false);

    return source.copyWith(
      categories: categories,
      contextSections: filteredSections,
    );
  }

  static String _categoryLabel(String category) {
    return switch (_normalizeKey(category)) {
      'travel' => 'Đời Xê Dịch',
      'daily' => 'Sinh hoạt hằng ngày',
      'work' => 'Công Sở',
      _ => _titleCase(category),
    };
  }

  static String _categoryIconKey(String category) {
    return switch (_normalizeKey(category)) {
      'travel' => 'travel',
      'daily' => 'restaurant',
      'work' => 'office',
      _ => _normalizeKey(category),
    };
  }

  static HomeAccentColor _categoryAccent(String category) {
    return switch (_normalizeKey(category)) {
      'travel' => HomeAccentColor.blue,
      'daily' => HomeAccentColor.green,
      'work' => HomeAccentColor.purple,
      _ => HomeAccentColor.orange,
    };
  }

  static HomeAccentColor _accentForIndex(int index) {
    return switch (index % 5) {
      0 => HomeAccentColor.green,
      1 => HomeAccentColor.blue,
      2 => HomeAccentColor.orange,
      3 => HomeAccentColor.pink,
      _ => HomeAccentColor.purple,
    };
  }

  static String _stringValue(
    Map<dynamic, dynamic> source,
    String key, {
    String fallback = '',
  }) {
    final value = source[key];
    if (value == null) {
      return fallback;
    }
    final text = value.toString();
    return text.isEmpty ? fallback : text;
  }

  static String _titleCase(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized.isEmpty) {
      return 'Context';
    }
    return normalized
        .split(RegExp(r'[_\s-]+'))
        .map(
          (part) => part.isEmpty
              ? part
              : '${part[0].toUpperCase()}${part.substring(1)}',
        )
        .join(' ');
  }

  static String _normalizeKey(String key) {
    return key.trim().toLowerCase().replaceAll(RegExp(r'[\s-]+'), '_');
  }
}
