class TreasureState {
  const TreasureState(this.items);

  final List<TreasureVocabulary> items;

  List<TreasureVocabulary> search(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return items;
    return items
        .where(
          (item) =>
              item.word.toLowerCase().contains(normalized) ||
              item.meaning.toLowerCase().contains(normalized),
        )
        .toList(growable: false);
  }
}

class TreasureVocabulary {
  const TreasureVocabulary({
    required this.vocabularyId,
    required this.word,
    required this.meaning,
    required this.partOfSpeech,
    required this.iconKey,
    required this.unlockedContextCount,
    required this.totalContextCount,
  });

  final String vocabularyId;
  final String word;
  final String meaning;
  final String partOfSpeech;
  final String iconKey;
  final int unlockedContextCount;
  final int totalContextCount;

  String get contextProgressLabel =>
      '$unlockedContextCount/$totalContextCount B\u1ed1i c\u1ea3nh';
}
