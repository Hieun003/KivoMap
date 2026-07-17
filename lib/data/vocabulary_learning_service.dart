import 'dart:convert';
import 'dart:math';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VocabularyLearningService {
  static const String _repetitionStatesKey = 'kivo.repetition_states.v1';
  static const String _discoveryTracesKey = 'kivo.discovery_traces.v1';
  static const String _discoveryActivitiesKey = 'kivo.discovery_activities.v1';

  final RxInt srsUpdateTrigger = 0.obs;

  final Map<String, RepetitionLearningState> _repetitionStates = {};
  final Map<String, Set<String>> _discoveredContextIdsByVocabulary = {};
  final Map<String, DiscoveryActivity> _discoveryActivities = {};
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    final preferences = await SharedPreferences.getInstance();
    _loadRepetitionStates(preferences.getString(_repetitionStatesKey));
    _loadDiscoveryTraces(preferences.getString(_discoveryTracesKey));
    _loadDiscoveryActivities(preferences.getString(_discoveryActivitiesKey));
    _isInitialized = true;
  }

  Future<void> recordDiscoveryContext({
    required String vocabularyId,
    required String knowledgeLinkId,
  }) async {
    await initialize();
    final contexts = _discoveredContextIdsByVocabulary.putIfAbsent(
      vocabularyId,
      () => <String>{},
    );
    final wasAdded = contexts.add(knowledgeLinkId);
    if (wasAdded) {
      await _saveDiscoveryTraces();
      final activity = DiscoveryActivity(
        vocabularyId: vocabularyId,
        knowledgeLinkId: knowledgeLinkId,
        discoveredAt: DateTime.now(),
      );
      _discoveryActivities[activity.key] = activity;
      await _saveDiscoveryActivities();
      srsUpdateTrigger.value++;
    }
  }

  Future<void> completeVocabularyLearning({
    required String vocabularyId,
    DateTime? completedAt,
  }) async {
    await initialize();
    if (_repetitionStates.containsKey(vocabularyId)) {
      return;
    }

    final now = completedAt ?? DateTime.now();
    const intervalDays = 0;
    _repetitionStates[vocabularyId] = RepetitionLearningState(
      vocabularyId: vocabularyId,
      masteryLevel: 0,
      intervalDays: intervalDays,
      easinessFactor: 2.5,
      reviewCount: 0,
      nextReviewAt: now.add(const Duration(minutes: 20)),
      lastReviewedAt: null,
      learnedAt: now,
    );
    await _saveRepetitionStates();
    srsUpdateTrigger.value++;
  }

  Map<String, RepetitionLearningState> repetitionStatesFor(
    Iterable<String> vocabularyIds,
  ) {
    final states = <String, RepetitionLearningState>{};
    for (final vocabularyId in vocabularyIds) {
      final state = _repetitionStates[vocabularyId];
      if (state != null) {
        states[vocabularyId] = state;
      }
    }
    return states;
  }

  /// Every vocabulary that has entered the user's local SRS history.
  /// Treasure uses this as its inclusion rule.
  Future<List<RepetitionLearningState>> learnedVocabularyStates() async {
    await initialize();
    final states = _repetitionStates.values.toList(growable: false)
      ..sort((a, b) => b.learnedAt.compareTo(a.learnedAt));
    return List<RepetitionLearningState>.unmodifiable(states);
  }

  Future<List<RepetitionLearningState>> dueRepetitionStates({
    int limit = 20,
  }) async {
    await initialize();
    final states =
        _repetitionStates.values
            .where((state) => state.isDue)
            .toList(growable: false)
          ..sort((a, b) {
            final levelCompare = a.masteryLevel.compareTo(b.masteryLevel);
            if (levelCompare != 0) return levelCompare;
            return a.nextReviewAt.compareTo(b.nextReviewAt);
          });
    return states.take(limit).toList(growable: false);
  }

  Future<DateTime?> getNextReviewTime() async {
    await initialize();
    final futureStates =
        _repetitionStates.values
            .where((state) => state.nextReviewAt.isAfter(DateTime.now()))
            .toList(growable: false)
          ..sort((a, b) => a.nextReviewAt.compareTo(b.nextReviewAt));
    return futureStates.firstOrNull?.nextReviewAt;
  }

  static int _getIntervalForLevel(int level) {
    return switch (level) {
      1 => 1,
      2 => 3,
      3 => 7,
      4 => 14,
      5 => 30,
      6 => 60,
      7 => 120,
      8 => 240,
      _ => 240,
    };
  }

  Future<void> completeVocabularyReview({
    required String vocabularyId,
    required Iterable<bool> attemptResults,
    DateTime? reviewedAt,
  }) async {
    await initialize();
    final attempts = attemptResults.toList(growable: false);
    if (attempts.isEmpty) {
      throw ArgumentError.value(attemptResults, 'attemptResults');
    }

    final now = reviewedAt ?? DateTime.now();
    final current =
        _repetitionStates[vocabularyId] ??
        RepetitionLearningState(
          vocabularyId: vocabularyId,
          masteryLevel: 1,
          intervalDays: 1,
          easinessFactor: 2.5,
          reviewCount: 0,
          nextReviewAt: now,
          lastReviewedAt: null,
          learnedAt: now,
        );

    final allCorrect = attempts.every((isCorrect) => isCorrect);
    final int nextMastery;
    if (allCorrect) {
      nextMastery = min(8, current.masteryLevel + 1);
    } else {
      if (current.masteryLevel == 0) {
        nextMastery = 0;
      } else {
        nextMastery = max(1, current.masteryLevel - 1);
      }
    }

    final nextInterval = nextMastery == 0
        ? 0
        : _getIntervalForLevel(nextMastery);
    final nextEase = allCorrect
        ? min(3.0, current.easinessFactor + 0.1)
        : max(1.3, current.easinessFactor - 0.2);

    final nextReviewAt = nextMastery == 0
        ? now.add(const Duration(minutes: 20))
        : now.add(Duration(days: nextInterval));

    _repetitionStates[vocabularyId] = RepetitionLearningState(
      vocabularyId: vocabularyId,
      masteryLevel: nextMastery,
      intervalDays: nextInterval,
      easinessFactor: nextEase,
      reviewCount: current.reviewCount + 1,
      nextReviewAt: nextReviewAt,
      lastReviewedAt: now,
      learnedAt: current.learnedAt,
    );
    await _saveRepetitionStates();
    srsUpdateTrigger.value++;
  }

  int discoveredContextCountFor(String vocabularyId) {
    return _discoveredContextIdsByVocabulary[vocabularyId]?.length ?? 0;
  }

  Future<Set<String>> discoveredContextIdsFor(String vocabularyId) async {
    await initialize();
    return Set<String>.unmodifiable(
      _discoveredContextIdsByVocabulary[vocabularyId] ?? const <String>{},
    );
  }

  Future<List<DiscoveryActivity>> recentDiscoveryActivities({
    int limit = 20,
  }) async {
    await initialize();
    final activities = _discoveryActivities.values.toList(growable: false)
      ..sort((a, b) => b.discoveredAt.compareTo(a.discoveredAt));
    return activities.take(limit).toList(growable: false);
  }

  Future<void> _saveDiscoveryActivities() async {
    final preferences = await SharedPreferences.getInstance();
    final payload = {
      for (final entry in _discoveryActivities.entries)
        entry.key: entry.value.toJson(),
    };
    await preferences.setString(_discoveryActivitiesKey, jsonEncode(payload));
  }

  Future<void> _saveRepetitionStates() async {
    final preferences = await SharedPreferences.getInstance();
    final payload = {
      for (final entry in _repetitionStates.entries)
        entry.key: entry.value.toJson(),
    };
    await preferences.setString(_repetitionStatesKey, jsonEncode(payload));
  }

  Future<void> _saveDiscoveryTraces() async {
    final preferences = await SharedPreferences.getInstance();
    final payload = {
      for (final entry in _discoveredContextIdsByVocabulary.entries)
        entry.key: entry.value.toList(growable: false),
    };
    await preferences.setString(_discoveryTracesKey, jsonEncode(payload));
  }

  void _loadRepetitionStates(String? raw) {
    if (raw == null || raw.isEmpty) {
      return;
    }

    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      return;
    }

    _repetitionStates
      ..clear()
      ..addEntries(
        decoded.entries.map((entry) {
          return MapEntry(
            entry.key.toString(),
            RepetitionLearningState.fromJson(entry.value),
          );
        }),
      );
  }

  void _loadDiscoveryTraces(String? raw) {
    if (raw == null || raw.isEmpty) {
      return;
    }

    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      return;
    }

    _discoveredContextIdsByVocabulary
      ..clear()
      ..addEntries(
        decoded.entries.map((entry) {
          final rawContextIds = entry.value;
          final contextIds = rawContextIds is List
              ? rawContextIds.map((id) => id.toString()).toSet()
              : <String>{};
          return MapEntry(entry.key.toString(), contextIds);
        }),
      );
  }

  void _loadDiscoveryActivities(String? raw) {
    if (raw == null || raw.isEmpty) return;
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return;
    _discoveryActivities
      ..clear()
      ..addEntries(
        decoded.entries.map((entry) {
          final activity = DiscoveryActivity.fromJson(entry.value);
          return MapEntry(entry.key.toString(), activity);
        }),
      );
  }
}

class DiscoveryActivity {
  const DiscoveryActivity({
    required this.vocabularyId,
    required this.knowledgeLinkId,
    required this.discoveredAt,
  });
  factory DiscoveryActivity.fromJson(Object? source) {
    final json = source is Map ? source : const <String, Object?>{};
    return DiscoveryActivity(
      vocabularyId: json['vocabularyId']?.toString() ?? '',
      knowledgeLinkId: json['knowledgeLinkId']?.toString() ?? '',
      discoveredAt:
          DateTime.tryParse(json['discoveredAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
  final String vocabularyId;
  final String knowledgeLinkId;
  final DateTime discoveredAt;
  String get key => '$vocabularyId::$knowledgeLinkId';
  Map<String, Object?> toJson() => {
    'vocabularyId': vocabularyId,
    'knowledgeLinkId': knowledgeLinkId,
    'discoveredAt': discoveredAt.toIso8601String(),
  };
}

class RepetitionLearningState {
  const RepetitionLearningState({
    required this.vocabularyId,
    required this.masteryLevel,
    required this.intervalDays,
    required this.easinessFactor,
    required this.reviewCount,
    required this.nextReviewAt,
    required this.lastReviewedAt,
    required this.learnedAt,
  });

  factory RepetitionLearningState.fromJson(Object? source) {
    final json = source is Map ? source : const <String, Object?>{};

    return RepetitionLearningState(
      vocabularyId: _stringValue(json, 'vocabularyId'),
      masteryLevel: _intValue(json, 'masteryLevel', fallback: 1),
      intervalDays: _intValue(json, 'intervalDays', fallback: 1),
      easinessFactor: _doubleValue(json, 'easinessFactor', fallback: 2.5),
      reviewCount: _intValue(json, 'reviewCount'),
      nextReviewAt: _dateValue(json, 'nextReviewAt'),
      lastReviewedAt: _nullableDateValue(json, 'lastReviewedAt'),
      learnedAt: _dateValue(json, 'learnedAt'),
    );
  }

  final String vocabularyId;
  final int masteryLevel;
  final int intervalDays;
  final double easinessFactor;
  final int reviewCount;
  final DateTime nextReviewAt;
  final DateTime? lastReviewedAt;
  final DateTime learnedAt;

  bool get isDue => !nextReviewAt.isAfter(DateTime.now());

  Map<String, Object?> toJson() {
    return {
      'vocabularyId': vocabularyId,
      'masteryLevel': masteryLevel,
      'intervalDays': intervalDays,
      'easinessFactor': easinessFactor,
      'reviewCount': reviewCount,
      'nextReviewAt': nextReviewAt.toIso8601String(),
      'lastReviewedAt': lastReviewedAt?.toIso8601String(),
      'learnedAt': learnedAt.toIso8601String(),
    };
  }

  static String _stringValue(Map<dynamic, dynamic> source, String key) {
    return source[key]?.toString() ?? '';
  }

  static int _intValue(
    Map<dynamic, dynamic> source,
    String key, {
    int fallback = 0,
  }) {
    return (source[key] as num?)?.toInt() ?? fallback;
  }

  static double _doubleValue(
    Map<dynamic, dynamic> source,
    String key, {
    required double fallback,
  }) {
    return (source[key] as num?)?.toDouble() ?? fallback;
  }

  static DateTime _dateValue(Map<dynamic, dynamic> source, String key) {
    return _nullableDateValue(source, key) ?? DateTime.now();
  }

  static DateTime? _nullableDateValue(
    Map<dynamic, dynamic> source,
    String key,
  ) {
    final value = source[key]?.toString();
    if (value == null || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }
}
