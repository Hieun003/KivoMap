import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';

import '../../../data/kivo_seed_data.dart';
import '../../../data/vocabulary_learning_service.dart';
import 'treasure_view_state.dart';

class TreasureViewModel extends GetxController {
  TreasureViewModel({VocabularyLearningService? learningService})
    : _learningService =
          learningService ?? Get.find<VocabularyLearningService>();

  final VocabularyLearningService _learningService;
  final RxBool isLoading = true.obs;
  final RxnString errorMessage = RxnString();
  final Rxn<TreasureState> state = Rxn<TreasureState>();
  final RxString searchQuery = ''.obs;
  Worker? _learningWorker;

  List<TreasureVocabulary> get filteredItems =>
      state.value?.search(searchQuery.value) ?? const <TreasureVocabulary>[];

  @override
  void onInit() {
    super.onInit();
    _learningWorker = ever(_learningService.srsUpdateTrigger, (_) => load());
    load();
  }

  @override
  void onClose() {
    _learningWorker?.dispose();
    super.onClose();
  }

  void updateSearch(String value) => searchQuery.value = value;

  void openVocabulary(TreasureVocabulary item) {
    Get.toNamed<void>(
      AppRoutes.vocabularyProfile,
      arguments: {
        'vocabularyId': item.vocabularyId,
        'partOfSpeech': item.partOfSpeech,
      },
    );
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final learnedStates = await _learningService.learnedVocabularyStates();
      final vocabulariesById = {
        for (final vocabulary in seedVocabularies)
          _stringValue(vocabulary, 'id'): vocabulary,
      };
      final totalContextsByVocabulary = <String, int>{};
      for (final link in seedKnowledgeLinks) {
        final vocabularyId = _stringValue(link, 'vocabularyId');
        totalContextsByVocabulary.update(
          vocabularyId,
          (count) => count + 1,
          ifAbsent: () => 1,
        );
      }

      final entries = <TreasureVocabulary>[];
      for (final learnedState in learnedStates) {
        final vocabulary = vocabulariesById[learnedState.vocabularyId];
        if (vocabulary == null) continue;
        final discoveredIds = await _learningService.discoveredContextIdsFor(
          learnedState.vocabularyId,
        );
        entries.add(
          TreasureVocabulary(
            vocabularyId: learnedState.vocabularyId,
            word: _stringValue(vocabulary, 'word'),
            meaning: _stringValue(vocabulary, 'meaning'),
            partOfSpeech: _stringValue(
              vocabulary,
              'partOfSpeech',
              fallback: _partOfSpeechFor(learnedState.vocabularyId),
            ),
            iconKey: _stringValue(vocabulary, 'iconKey', fallback: 'default'),
            unlockedContextCount: discoveredIds.length,
            totalContextCount:
                totalContextsByVocabulary[learnedState.vocabularyId] ?? 0,
          ),
        );
      }
      state.value = TreasureState(List.unmodifiable(entries));
    } catch (_) {
      errorMessage.value =
          'Kh\u00f4ng th\u1ec3 m\u1edf Kho b\u00e1u. H\u00e3y th\u1eed l\u1ea1i nh\u00e9.';
    } finally {
      isLoading.value = false;
    }
  }

  static String _partOfSpeechFor(String vocabularyId) =>
      _partOfSpeechByVocabularyId[vocabularyId] ?? 'T\u1eeb v\u1ef1ng';

  static const Map<String, String> _partOfSpeechByVocabularyId = {
    'vocab_spill': '\u0110\u1ed9ng t\u1eeb',
    'vocab_barista': 'Danh t\u1eeb',
    'vocab_takeaway': 'Danh t\u1eeb',
    'vocab_decaf': 'Danh t\u1eeb',
    'vocab_receipt': 'Danh t\u1eeb',
    'vocab_drizzle': '\u0110\u1ed9ng t\u1eeb',
    'vocab_dead': 'T\u00ednh t\u1eeb',
    'vocab_landmark': 'Danh t\u1eeb',
    'vocab_intersection': 'Danh t\u1eeb',
    'vocab_shortcut': 'Danh t\u1eeb',
    'vocab_lost': 'T\u00ednh t\u1eeb',
    'vocab_directions': 'Danh t\u1eeb',
    'vocab_surge': 'Danh t\u1eeb',
    'vocab_shelter': 'Danh t\u1eeb',
    'vocab_cancel': '\u0110\u1ed9ng t\u1eeb',
    'vocab_drenched': 'T\u00ednh t\u1eeb',
    'vocab_pickup': 'Danh t\u1eeb',
    'vocab_stuck': 'T\u00ednh t\u1eeb',
    'vocab_vendor': 'Danh t\u1eeb',
    'vocab_stall': 'Danh t\u1eeb',
    'vocab_spicy': 'T\u00ednh t\u1eeb',
    'vocab_cash': 'Danh t\u1eeb',
    'vocab_hygiene': 'Danh t\u1eeb',
    'vocab_specialty': 'Danh t\u1eeb',
    'vocab_booking': 'Danh t\u1eeb',
    'vocab_overbooked': 'T\u00ednh t\u1eeb',
    'vocab_upgrade': 'Danh t\u1eeb',
    'vocab_late_checkin': 'Danh t\u1eeb',
    'vocab_deposit': 'Danh t\u1eeb',
    'vocab_available': 'T\u00ednh t\u1eeb',
  };
  static String _stringValue(
    Map<String, Object?> source,
    String key, {
    String fallback = '',
  }) => source[key]?.toString() ?? fallback;
}
