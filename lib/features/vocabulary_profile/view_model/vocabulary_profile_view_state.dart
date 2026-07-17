class VocabularyProfileState {
  const VocabularyProfileState({
    required this.vocabularyId,
    required this.clusterId,
    required this.word,
    required this.meaning,
    required this.partOfSpeech,
    required this.pronunciation,
    required this.iconKey,
    required this.contexts,
  });

  final String vocabularyId;
  final String clusterId;
  final String word;
  final String meaning;
  final String partOfSpeech;
  final String pronunciation;
  final String iconKey;
  final List<VocabularyProfileContext> contexts;

  int get unlockedContextCount =>
      contexts.where((context) => context.isUnlocked).length;
  int get totalContextCount => contexts.length;
}

class VocabularyProfileContext {
  const VocabularyProfileContext({
    required this.knowledgeLinkId,
    required this.title,
    required this.translation,
    required this.example,
    required this.isUnlocked,
  });

  final String knowledgeLinkId;
  final String title;
  final String translation;
  final String example;
  final bool isUnlocked;
}
