import 'dart:async';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/routes/app_routes.dart';
import '../../../data/kivo_seed_data.dart';
import '../../../data/vocabulary_learning_service.dart';
import '../../../data/energy_service.dart';
import 'home_view_state.dart';

class HomeViewModel extends GetxController {
  HomeViewModel({
    VocabularyLearningService? learningService,
    EnergyService? energyService,
  })  : _learningService = learningService ?? Get.find<VocabularyLearningService>(),
        _energyService = energyService ?? Get.find<EnergyService>();

  final VocabularyLearningService _learningService;
  final EnergyService _energyService;
  final RxBool isLoading = true.obs;
  final RxnString errorMessage = RxnString();
  final Rxn<HomeDashboardState> state = Rxn<HomeDashboardState>();
  final RxString bannerCountdownText = ''.obs;

  HomeDashboardState? _sourceState;
  Timer? _bannerTimer;

  @override
  void onInit() {
    super.onInit();
    // Re-evaluate energy/streak values dynamically when service signals change
    ever(_energyService.energy, (_) => _updateEnergyAndStreak());
    ever(_energyService.streakDays, (_) => _updateEnergyAndStreak());
    ever(_learningService.srsUpdateTrigger, (_) => load());
    load();
  }

  Future<void> _resetAndLoad() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Get.log('KIVO: Reset all SharedPreferences data successfully!');
    await load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      await _learningService.initialize();
      await _energyService.initialize();
      final allVocabularyIds = seedVocabularies
          .map((v) => _stringValue(v, 'id'))
          .toList(growable: false);
      final repetitionStates = _learningService.repetitionStatesFor(
        allVocabularyIds,
      );
      final dueStates = await _learningService.dueRepetitionStates(limit: 1);
      _sourceState = _buildStateFromSeed(
        repetitionStates: repetitionStates,
        hasDue: dueStates.isNotEmpty,
      );
      state.value = _buildFilteredState(selectedCategoryKey: 'default');
      _updateBannerCountdown();
    } catch (_) {
      errorMessage.value =
          'Kh\u00f4ng th\u1ec3 t\u1ea3i trang ch\u1ee7. H\u00e3y th\u1eed l\u1ea1i nh\u00e9.';
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _bannerTimer?.cancel();
    super.onClose();
  }

  void _updateBannerCountdown() {
    _bannerTimer?.cancel();
    final currentState = state.value;
    if (currentState == null || currentState.bannerStatus != HomeReviewBannerStatus.noDueReview) {
      bannerCountdownText.value = '';
      return;
    }

    _runBannerCountdownTick();
    _bannerTimer = Timer.periodic(const Duration(minutes: 1), (_) => _runBannerCountdownTick());
  }

  Future<void> _reloadSrsStateOnly() async {
    try {
      final allVocabularyIds = seedVocabularies
          .map((v) => _stringValue(v, 'id'))
          .toList(growable: false);
      final repetitionStates = _learningService.repetitionStatesFor(
        allVocabularyIds,
      );
      final dueStates = await _learningService.dueRepetitionStates(limit: 1);
      _sourceState = _buildStateFromSeed(
        repetitionStates: repetitionStates,
        hasDue: dueStates.isNotEmpty,
      );
      state.value = _buildFilteredState(selectedCategoryKey: 'default');
      _updateBannerCountdown();
    } catch (_) {
      // Âm thầm bỏ qua lỗi trong nền
    }
  }

  Future<void> _runBannerCountdownTick() async {
    final nextTime = await _learningService.getNextReviewTime();
    if (nextTime == null) {
      bannerCountdownText.value = '';
      _bannerTimer?.cancel();
      _reloadSrsStateOnly();
      return;
    }

    final diff = nextTime.difference(DateTime.now());
    if (diff.isNegative) {
      bannerCountdownText.value = '';
      _bannerTimer?.cancel();
      _reloadSrsStateOnly();
      return;
    }

    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;
    if (hours > 0) {
      bannerCountdownText.value = 'Ôn tập sau: ${hours}h ${minutes}m ⏳';
    } else if (minutes > 0) {
      bannerCountdownText.value = 'Ôn tập sau: ${minutes}p ⏳';
    } else {
      bannerCountdownText.value = 'Sắp đến hạn ôn tập... ⏳';
    }
  }

  void _updateEnergyAndStreak() {
    final current = state.value;
    if (current == null) return;
    state.value = HomeDashboardState(
      userName: current.userName,
      roleLabel: current.roleLabel,
      energy: _energyService.energy.value,
      maxEnergy: EnergyService.maxEnergy,
      streakDays: _energyService.streakDays.value,
      bannerStatus: current.bannerStatus,
      categories: current.categories,
      contextSections: current.contextSections,
    );
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
    Get.toNamed(AppRoutes.review);
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

  HomeDashboardState _buildStateFromSeed({
    required Map<String, RepetitionLearningState> repetitionStates,
    required bool hasDue,
  }) {
    final sectionsByCategory = <String, List<HomeContextTopicData>>{};

    for (
      var clusterIndex = 0;
      clusterIndex < seedClusters.length;
      clusterIndex++
    ) {
      final cluster = seedClusters[clusterIndex];
      final clusterId = _stringValue(cluster, 'id');
      final category = _stringValue(cluster, 'category', fallback: 'DAILY');
      final clusterVocabIds = seedVocabularies
          .where(
            (vocabulary) => _stringValue(vocabulary, 'clusterId') == clusterId,
          )
          .map((v) => _stringValue(v, 'id'))
          .toList(growable: false);
      final totalCount = clusterVocabIds.isEmpty ? 1 : clusterVocabIds.length;
      final learnedCount = clusterVocabIds
          .where((id) => repetitionStates.containsKey(id))
          .length;
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

    final totalInSrs = repetitionStates.length;
    final bannerStatus = totalInSrs == 0
        ? HomeReviewBannerStatus.noWords
        : hasDue
        ? HomeReviewBannerStatus.reviewDue
        : HomeReviewBannerStatus.noDueReview;

    return HomeDashboardState(
      userName: 'Explorer',
      roleLabel: 'Explorer',
      energy: _energyService.energy.value,
      maxEnergy: EnergyService.maxEnergy,
      streakDays: _energyService.streakDays.value,
      bannerStatus: bannerStatus,
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
