import 'dart:math';

import 'package:get/get.dart';

import '../../../data/energy_service.dart';
import '../../../data/kivo_seed_data.dart';
import '../../../data/vocabulary_learning_service.dart';
import 'review_view_state.dart';

class ReviewViewModel extends GetxController {
  ReviewViewModel({
    VocabularyLearningService? learningService,
    EnergyService? energyService,
  })  : _learningService = learningService ?? Get.find<VocabularyLearningService>(),
        _energyService = energyService ?? Get.find<EnergyService>();

  static const int _questionCount = 3;
  static const int _optionCount = 4;

  final VocabularyLearningService _learningService;
  final EnergyService _energyService;
  final Random _random = Random();
  final RxBool isLoading = true.obs;
  final RxnString errorMessage = RxnString();
  final Rxn<ReviewSessionState> state = Rxn<ReviewSessionState>();
  final List<bool> _attemptResults = <bool>[];

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      await _learningService.initialize();
      await _energyService.initialize();
      final vocabulary = await _nextVocabularyForReview();
      final nextState = _stateFromVocabulary(vocabulary);
      state.value = nextState;
      _attemptResults.clear();
    } catch (_) {
      errorMessage.value = 'Chưa thể mở phiên ôn tập. Hãy thử lại nhé.';
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Future<void> refresh() => load();

  void goBack() {
    Get.back<void>();
  }

  void selectOption(ReviewAnswerOptionData option) {
    final currentState = state.value;
    if (currentState == null ||
        currentState.hasSelection ||
        currentState.isComplete) {
      return;
    }

    final isCorrect = option.id == currentState.currentQuestion.correctOptionId;
    _attemptResults.add(isCorrect);
    state.value = currentState.copyWith(
      selectedOptionId: option.id,
      correctCount: currentState.correctCount + (isCorrect ? 1 : 0),
    );
  }

  Future<void> continueReview() async {
    final currentState = state.value;
    if (currentState == null || !currentState.hasSelection) {
      return;
    }

    if (currentState.currentQuestionIndex < currentState.questions.length - 1) {
      state.value = currentState.copyWith(
        currentQuestionIndex: currentState.currentQuestionIndex + 1,
        clearSelectedOption: true,
      );
      return;
    }

    await _learningService.completeVocabularyReview(
      vocabularyId: currentState.vocabularyId,
      attemptResults: _attemptResults,
    );
    await _energyService.recordActivity();
    state.value = currentState.copyWith(isComplete: true);
  }

  Future<Map<String, Object?>> _nextVocabularyForReview() async {
    final args = Get.arguments;
    final requestedVocabularyId = args is Map
        ? args['vocabularyId']?.toString()
        : null;
    if (requestedVocabularyId != null && requestedVocabularyId.isNotEmpty) {
      final requested = _findById(seedVocabularies, requestedVocabularyId);
      if (requested != null) {
        return requested;
      }
    }

    final dueStates = await _learningService.dueRepetitionStates(limit: 20);
    for (final dueState in dueStates) {
      final vocabulary = _findById(seedVocabularies, dueState.vocabularyId);
      if (vocabulary != null) {
        return vocabulary;
      }
    }

    return seedVocabularies.first;
  }

  ReviewSessionState _stateFromVocabulary(Map<String, Object?> vocabulary) {
    final vocabularyId = _stringValue(vocabulary, 'id');
    final clusterId = _stringValue(vocabulary, 'clusterId');
    final links =
        seedKnowledgeLinks
            .where((link) => _stringValue(link, 'vocabularyId') == vocabularyId)
            .toList(growable: false)
          ..shuffle(_random);

    final selectedLinks = links.take(_questionCount).toList(growable: false);
    if (selectedLinks.length < _questionCount) {
      throw StateError(
        'Vocabulary $vocabularyId needs $_questionCount contexts.',
      );
    }

    final clusterOptions = seedVocabularies
        .where((item) => _stringValue(item, 'clusterId') == clusterId)
        .toList(growable: false);
    final questions = selectedLinks
        .map((link) {
          return ReviewQuestionData(
            knowledgeLinkId: _stringValue(link, 'id'),
            segments: _maskContextExample(
              _stringValue(link, 'contextExample'),
              _stringValue(vocabulary, 'word'),
            ),
            options: _answerOptions(vocabulary, clusterOptions),
            correctOptionId: vocabularyId,
          );
        })
        .toList(growable: false);

    return ReviewSessionState(
      userName: 'Explorer',
      roleLabel: 'Explorer',
      energy: _energyService.energy.value,
      maxEnergy: EnergyService.maxEnergy,
      streakDays: _energyService.streakDays.value,
      vocabularyId: vocabularyId,
      vocabularyWord: _stringValue(vocabulary, 'word'),
      vocabularyMeaning: _stringValue(vocabulary, 'meaning'),
      questions: questions,
      currentQuestionIndex: 0,
      selectedOptionId: null,
      isComplete: false,
      correctCount: 0,
    );
  }

  List<ReviewAnswerOptionData> _answerOptions(
    Map<String, Object?> correctVocabulary,
    List<Map<String, Object?>> clusterVocabularies,
  ) {
    final correctId = _stringValue(correctVocabulary, 'id');
    final distractors =
        clusterVocabularies
            .where((item) => _stringValue(item, 'id') != correctId)
            .toList(growable: false)
          ..shuffle(_random);
    final rawOptions = <Map<String, Object?>>[
      correctVocabulary,
      ...distractors.take(_optionCount - 1),
    ]..shuffle(_random);

    return rawOptions
        .map((item) {
          return ReviewAnswerOptionData(
            id: _stringValue(item, 'id'),
            word: _stringValue(item, 'word'),
            meaning: _stringValue(item, 'meaning'),
            iconKey: _stringValue(item, 'iconKey', fallback: 'default'),
          );
        })
        .toList(growable: false);
  }

  List<ReviewSentenceSegment> _maskContextExample(
    String source,
    String targetWord,
  ) {
    final segments = <ReviewSentenceSegment>[];
    final boldPattern = RegExp(r'\*\*(.*?)\*\*');
    var cursor = 0;
    var masked = false;

    for (final match in boldPattern.allMatches(source)) {
      if (match.start > cursor) {
        segments.add(
          ReviewSentenceSegment(text: source.substring(cursor, match.start)),
        );
      }
      final highlighted = match.group(1) ?? '';
      final maskedText = _replaceTarget(highlighted, targetWord);
      masked = masked || maskedText != highlighted;
      segments.add(
        ReviewSentenceSegment(
          text: maskedText,
          isHighlighted: true,
          isBlank: maskedText.contains('[ ? ]'),
        ),
      );
      cursor = match.end;
    }

    if (cursor < source.length) {
      final tail = source.substring(cursor);
      final maskedTail = masked ? tail : _replaceTarget(tail, targetWord);
      masked = masked || maskedTail != tail;
      segments.add(
        ReviewSentenceSegment(
          text: maskedTail,
          isBlank: maskedTail.contains('[ ? ]'),
        ),
      );
    }

    if (!masked && segments.isNotEmpty) {
      final firstHighlight = segments.indexWhere(
        (segment) => segment.isHighlighted,
      );
      if (firstHighlight >= 0) {
        segments[firstHighlight] = const ReviewSentenceSegment(
          text: '[ ? ]',
          isHighlighted: true,
          isBlank: true,
        );
      }
    }

    return segments;
  }

  String _replaceTarget(String source, String targetWord) {
    if (targetWord.isEmpty) {
      return source;
    }
    final escaped = RegExp.escape(targetWord);
    final pattern = RegExp('\\b$escaped\\b', caseSensitive: false);
    return source.replaceFirst(pattern, '[ ? ]');
  }

  Map<String, Object?>? _findById(
    List<Map<String, Object?>> source,
    String id,
  ) {
    for (final item in source) {
      if (_stringValue(item, 'id') == id) {
        return item;
      }
    }
    return null;
  }

  String _stringValue(
    Map<String, Object?> source,
    String key, {
    String fallback = '',
  }) {
    return source[key]?.toString() ?? fallback;
  }
}
