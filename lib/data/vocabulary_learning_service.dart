import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class VocabularyLearningService {
  static const String _repetitionStatesKey = 'kivo.repetition_states.v1';
  static const String _discoveryTracesKey = 'kivo.discovery_traces.v1';

  final Map<String, RepetitionLearningState> _repetitionStates = {};
  final Map<String, Set<String>> _discoveredContextIdsByVocabulary = {};
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    final preferences = await SharedPreferences.getInstance();
    _loadRepetitionStates(preferences.getString(_repetitionStatesKey));
    _loadDiscoveryTraces(preferences.getString(_discoveryTracesKey));
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
    const intervalDays = 1;
    _repetitionStates[vocabularyId] = RepetitionLearningState(
      vocabularyId: vocabularyId,
      masteryLevel: 1,
      intervalDays: intervalDays,
      easinessFactor: 2.5,
      reviewCount: 0,
      nextReviewAt: now.add(const Duration(days: intervalDays)),
      lastReviewedAt: null,
      learnedAt: now,
    );
    await _saveRepetitionStates();
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

  int discoveredContextCountFor(String vocabularyId) {
    return _discoveredContextIdsByVocabulary[vocabularyId]?.length ?? 0;
  }

  Future<Set<String>> discoveredContextIdsFor(String vocabularyId) async {
    await initialize();
    return Set<String>.unmodifiable(
      _discoveredContextIdsByVocabulary[vocabularyId] ?? const <String>{},
    );
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
