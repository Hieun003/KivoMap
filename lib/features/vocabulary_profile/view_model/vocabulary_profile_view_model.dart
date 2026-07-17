import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../data/kivo_seed_data.dart';
import '../../../data/vocabulary_learning_service.dart';
import 'vocabulary_profile_view_state.dart';

class VocabularyProfileViewModel extends GetxController {
  VocabularyProfileViewModel({VocabularyLearningService? learningService})
    : _learningService =
          learningService ?? Get.find<VocabularyLearningService>();

  final VocabularyLearningService _learningService;
  final RxBool isLoading = true.obs;
  final RxnString errorMessage = RxnString();
  final Rxn<VocabularyProfileState> state = Rxn<VocabularyProfileState>();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final arguments = Get.arguments;
      final args = arguments is Map ? arguments : const <Object?, Object?>{};
      final vocabularyId = args['vocabularyId']?.toString() ?? '';
      if (vocabularyId.isEmpty) {
        throw StateError('Missing vocabularyId');
      }

      Map<String, Object?>? vocabulary;
      for (final candidate in seedVocabularies) {
        if (_stringValue(candidate, 'id') == vocabularyId) {
          vocabulary = candidate;
          break;
        }
      }
      if (vocabulary == null) throw StateError('Vocabulary not found');

      final discoveredIds = await _learningService.discoveredContextIdsFor(
        vocabularyId,
      );
      final links = seedKnowledgeLinks
          .where((link) => _stringValue(link, 'vocabularyId') == vocabularyId)
          .toList(growable: false);

      state.value = VocabularyProfileState(
        vocabularyId: vocabularyId,
        clusterId: _stringValue(vocabulary, 'clusterId'),
        word: _stringValue(vocabulary, 'word'),
        meaning: _stringValue(vocabulary, 'meaning'),
        partOfSpeech: args['partOfSpeech']?.toString() ?? 'T\u1eeb v\u1ef1ng',
        pronunciation: _stringValue(vocabulary, 'pronunciation'),
        iconKey: _stringValue(vocabulary, 'iconKey', fallback: 'default'),
        contexts: [
          for (final link in links)
            VocabularyProfileContext(
              knowledgeLinkId: _stringValue(link, 'id'),
              title: _titleCase(_stringValue(link, 'anchorWord')),
              translation: _stringValue(link, 'anchorWordVi'),
              example: _stringValue(link, 'contextExample'),
              isUnlocked: discoveredIds.contains(_stringValue(link, 'id')),
            ),
        ],
      );
    } catch (_) {
      errorMessage.value =
          'Kh\u00f4ng th\u1ec3 m\u1edf h\u1ed3 s\u01a1 t\u1eeb v\u1ef1ng n\u00e0y.';
    } finally {
      isLoading.value = false;
    }
  }

  void goBack() => Get.back<void>();

  void playPronunciation() {
    Get.snackbar(
      'Ph\u00e1t \u00e2m',
      'Audio cho t\u1eeb n\u00e0y \u0111ang \u0111\u01b0\u1ee3c Kivo c\u1eadp nh\u1eadt.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void continueDiscovery() {
    final current = state.value;
    if (current == null) return;
    Get.toNamed<void>(
      AppRoutes.discoveryMatrix,
      arguments: {
        'vocabularyId': current.vocabularyId,
        'clusterId': current.clusterId,
      },
    );
  }

  static String _titleCase(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'B\u1ed1i c\u1ea3nh';
    return '${trimmed[0].toUpperCase()}${trimmed.substring(1)}';
  }

  static String _stringValue(
    Map<String, Object?> source,
    String key, {
    String fallback = '',
  }) => source[key]?.toString() ?? fallback;
}
