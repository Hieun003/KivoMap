import 'package:flutter_test/flutter_test.dart';
import 'package:kivo_map/features/treasure/view_model/treasure_view_state.dart';

void main() {
  const passport = TreasureVocabulary(
    vocabularyId: 'passport',
    word: 'Passport',
    meaning: 'Hộ chiếu',
    partOfSpeech: 'Danh từ',
    iconKey: 'passport',
    unlockedContextCount: 3,
    totalContextCount: 5,
  );
  const luggage = TreasureVocabulary(
    vocabularyId: 'luggage',
    word: 'Luggage',
    meaning: 'Hành lý',
    partOfSpeech: 'Danh từ',
    iconKey: 'luggage',
    unlockedContextCount: 2,
    totalContextCount: 4,
  );

  group('TreasureState', () {
    const state = TreasureState([passport, luggage]);

    test('keeps only vocabulary with a matching English word', () {
      expect(state.search('pass'), [passport]);
    });

    test('searches Vietnamese meanings without case sensitivity', () {
      expect(state.search('HÀNH'), [luggage]);
    });

    test('returns all entries for an empty query', () {
      expect(state.search('  '), [passport, luggage]);
    });

    test('formats its context-progress label', () {
      expect(passport.contextProgressLabel, '3/5 B\u1ed1i c\u1ea3nh');
    });
  });
}
