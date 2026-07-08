class ReviewSessionState {
  const ReviewSessionState({
    required this.userName,
    required this.roleLabel,
    required this.energy,
    required this.maxEnergy,
    required this.streakDays,
    required this.vocabularyId,
    required this.vocabularyWord,
    required this.vocabularyMeaning,
    required this.questions,
    required this.currentQuestionIndex,
    required this.selectedOptionId,
    required this.isComplete,
    required this.correctCount,
  });

  final String userName;
  final String roleLabel;
  final int energy;
  final int maxEnergy;
  final int streakDays;
  final String vocabularyId;
  final String vocabularyWord;
  final String vocabularyMeaning;
  final List<ReviewQuestionData> questions;
  final int currentQuestionIndex;
  final String? selectedOptionId;
  final bool isComplete;
  final int correctCount;

  ReviewQuestionData get currentQuestion => questions[currentQuestionIndex];
  int get answeredCount => isComplete ? questions.length : currentQuestionIndex;
  int get totalCount => questions.length;
  double get progressRatio => totalCount == 0 ? 0 : answeredCount / totalCount;
  bool get hasSelection => selectedOptionId != null;

  ReviewSessionState copyWith({
    int? currentQuestionIndex,
    String? selectedOptionId,
    bool clearSelectedOption = false,
    bool? isComplete,
    int? correctCount,
  }) {
    return ReviewSessionState(
      userName: userName,
      roleLabel: roleLabel,
      energy: energy,
      maxEnergy: maxEnergy,
      streakDays: streakDays,
      vocabularyId: vocabularyId,
      vocabularyWord: vocabularyWord,
      vocabularyMeaning: vocabularyMeaning,
      questions: questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      selectedOptionId: clearSelectedOption
          ? null
          : selectedOptionId ?? this.selectedOptionId,
      isComplete: isComplete ?? this.isComplete,
      correctCount: correctCount ?? this.correctCount,
    );
  }
}

class ReviewQuestionData {
  const ReviewQuestionData({
    required this.knowledgeLinkId,
    required this.segments,
    required this.options,
    required this.correctOptionId,
  });

  final String knowledgeLinkId;
  final List<ReviewSentenceSegment> segments;
  final List<ReviewAnswerOptionData> options;
  final String correctOptionId;
}

class ReviewSentenceSegment {
  const ReviewSentenceSegment({
    required this.text,
    this.isHighlighted = false,
    this.isBlank = false,
  });

  final String text;
  final bool isHighlighted;
  final bool isBlank;
}

class ReviewAnswerOptionData {
  const ReviewAnswerOptionData({
    required this.id,
    required this.word,
    required this.meaning,
    required this.iconKey,
  });

  final String id;
  final String word;
  final String meaning;
  final String iconKey;
}
