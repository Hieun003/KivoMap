import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/theme/kivo_theme_tokens.dart';
import '../../../data/kivo_seed_data.dart';
import 'discovery_view_state.dart';

class DiscoveryViewModel extends GetxController {
  final RxBool isLoading = true.obs;
  final RxnString errorMessage = RxnString();
  final Rxn<DiscoveryMatrixState> state = Rxn<DiscoveryMatrixState>();
  final RxnString selectedContextId = RxnString();
  final RxSet<String> discoveredContextIds = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final args = Get.arguments;
      final vocabularyId = args is Map ? args['vocabularyId'] as String? : null;
      final clusterId = args is Map ? args['clusterId'] as String? : null;
      state.value = _stateFromSeed(
        vocabularyId: vocabularyId,
        clusterId: clusterId,
      );
      selectedContextId.value = null;
      discoveredContextIds.clear();
    } catch (_) {
      errorMessage.value =
          'Kh\u00f4ng th\u1ec3 m\u1edf Ma tr\u1eadn Kh\u00e1m ph\u00e1. H\u00e3y th\u1eed l\u1ea1i nh\u00e9.';
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Future<void> refresh() => load();

  void goBack() {
    Get.back<void>();
  }

  void continueLearning() {
    final currentState = state.value;
    if (currentState == null) {
      Get.back<void>();
      return;
    }

    final nextVocabularyId = currentState.nextVocabularyId;
    if (nextVocabularyId == null) {
      Get.offNamed(
        AppRoutes.vocabularyPlanet,
        arguments: {'clusterId': currentState.clusterId},
      );
      return;
    }

    Get.offNamed(
      AppRoutes.discoveryMatrix,
      arguments: {
        'clusterId': currentState.clusterId,
        'vocabularyId': nextVocabularyId,
      },
    );
  }

  bool selectContext(DiscoveryContextNode context) {
    discoveredContextIds.add(context.id);
    discoveredContextIds.refresh();
    selectedContextId.value = context.id;
    return true;
  }

  DiscoveryMatrixState _stateFromSeed({
    required String? vocabularyId,
    required String? clusterId,
  }) {
    final vocabulary = _findVocabulary(vocabularyId, clusterId);
    final resolvedVocabularyId = _stringValue(vocabulary, 'id');
    final resolvedClusterId = _stringValue(vocabulary, 'clusterId');
    final nextVocabulary = _nextVocabulary(
      resolvedVocabularyId,
      resolvedClusterId,
    );
    final links = seedKnowledgeLinks
        .where(
          (link) => _stringValue(link, 'vocabularyId') == resolvedVocabularyId,
        )
        .take(5)
        .toList(growable: false);

    final contexts = <DiscoveryContextNode>[
      for (var i = 0; i < links.length; i++)
        _contextFromSeedLink(links[i], order: i + 1),
    ];

    return DiscoveryMatrixState(
      clusterId: resolvedClusterId,
      vocabularyId: resolvedVocabularyId,
      nextVocabularyId: nextVocabulary == null
          ? null
          : _stringValue(nextVocabulary, 'id'),
      nextVocabularyLabel: nextVocabulary == null
          ? null
          : _titleCase(_stringValue(nextVocabulary, 'word')),
      title: 'Ma tr\u1eadn Kh\u00e1m ph\u00e1',
      subtitle: '(Discover Matrix)',
      root: DiscoveryRootNode(
        label: _titleCase(_stringValue(vocabulary, 'word')),
        translation: _stringValue(vocabulary, 'meaning'),
        iconKey: _stringValue(vocabulary, 'iconKey', fallback: 'default'),
        accentColor: KivoColors.targetPurple,
      ),
      contexts: contexts,
      englishChunks: contexts.isEmpty
          ? _chunksFromExample(
              _stringValue(vocabulary, 'example'),
              languageLabel: 'EN',
              targetWord: _stringValue(vocabulary, 'word'),
            )
          : contexts.first.englishChunks,
      vietnameseChunks: contexts.isEmpty
          ? _chunksFromExample(
              _stringValue(vocabulary, 'exampleVi'),
              languageLabel: 'VI',
              targetWord: _stringValue(vocabulary, 'meaning'),
            )
          : contexts.first.vietnameseChunks,
    );
  }

  Map<String, Object?> _findVocabulary(
    String? vocabularyId,
    String? clusterId,
  ) {
    if (vocabularyId != null) {
      final found = _findById(seedVocabularies, vocabularyId);
      if (found != null) {
        return found;
      }
    }

    if (clusterId != null) {
      for (final vocabulary in seedVocabularies) {
        if (_stringValue(vocabulary, 'clusterId') == clusterId) {
          return vocabulary;
        }
      }
    }

    return seedVocabularies.first;
  }

  DiscoveryContextNode _contextFromSeedLink(
    Map<String, Object?> link, {
    required int order,
  }) {
    final anchorWord = _stringValue(link, 'anchorWord');
    final anchorVocabulary = _findVocabularyByWord(
      _stringValue(link, 'clusterId'),
      anchorWord,
    );
    final detail = _findDetailForLink(_stringValue(link, 'id'));
    final alignment = _alignmentFor(order);
    const status = DiscoveryContextStatus.available;

    return DiscoveryContextNode(
      id: _stringValue(link, 'id'),
      order: order,
      title: _titleCase(anchorWord),
      translation: _stringValue(
        link,
        'anchorWordVi',
        fallback: _stringValue(
          anchorVocabulary,
          'meaning',
          fallback: anchorWord,
        ),
      ),
      iconKey: _stringValue(anchorVocabulary, 'iconKey', fallback: 'default'),
      alignment: alignment,
      status: status,
      sentence: _cleanInlineMarkup(_stringValue(link, 'contextExample')),
      sentenceVi: _cleanInlineMarkup(_stringValue(link, 'contextExampleVi')),
      englishChunks: _chunksFromExample(
        _stringValue(link, 'contextExample'),
        languageLabel: 'EN',
        targetWord: _stringValue(
          _findById(seedVocabularies, _stringValue(link, 'vocabularyId')),
          'word',
        ),
      ),
      vietnameseChunks: _chunksFromExample(
        _stringValue(link, 'contextExampleVi'),
        languageLabel: 'VI',
        targetWord: _stringValue(
          _findById(seedVocabularies, _stringValue(link, 'vocabularyId')),
          'meaning',
        ),
      ),
      dialogue: _dialogueFromDetail(detail),
      tip: _stringValue(
        detail,
        'realWorldTipVi',
        fallback: _stringValue(detail, 'realWorldTip'),
      ),
    );
  }

  Map<String, Object?>? _nextVocabulary(String vocabularyId, String clusterId) {
    final clusterVocabulary = seedVocabularies
        .where(
          (vocabulary) =>
              _stringValue(vocabulary, 'clusterId') == clusterId &&
              vocabulary['isPlanet'] != false,
        )
        .toList(growable: false);

    for (var i = 0; i < clusterVocabulary.length; i += 1) {
      if (_stringValue(clusterVocabulary[i], 'id') == vocabularyId) {
        return i + 1 < clusterVocabulary.length
            ? clusterVocabulary[i + 1]
            : null;
      }
    }

    return null;
  }

  Map<String, Object?>? _findById(List<Map<String, Object?>> items, String id) {
    for (final item in items) {
      if (_stringValue(item, 'id') == id) {
        return item;
      }
    }
    return null;
  }

  Map<String, Object?>? _findVocabularyByWord(String clusterId, String word) {
    final normalizedWord = word.trim().toLowerCase();
    for (final vocabulary in seedVocabularies) {
      if (_stringValue(vocabulary, 'clusterId') == clusterId &&
          _stringValue(vocabulary, 'word').trim().toLowerCase() ==
              normalizedWord) {
        return vocabulary;
      }
    }
    return null;
  }

  Map<String, Object?>? _findDetailForLink(String linkId) {
    for (final detail in seedContextDetails) {
      if (_stringValue(detail, 'knowledgeLinkId') == linkId) {
        return detail;
      }
    }
    return null;
  }

  List<DiscoveryDialogueLine> _dialogueFromDetail(
    Map<String, Object?>? detail,
  ) {
    final dialogue = _dialogueListFromRaw(detail?['miniDialogue']);
    final translations = _dialogueListFromRaw(detail?['miniDialogueVi']);
    if (dialogue.isEmpty) {
      return const [];
    }

    return [
      for (var i = 0; i < dialogue.length; i += 1)
        DiscoveryDialogueLine(
          speaker: _stringValue(dialogue[i], 'speaker'),
          text: _stringValue(dialogue[i], 'text'),
          translation: i < translations.length
              ? _stringValue(translations[i], 'text')
              : '',
        ),
    ];
  }

  List<Map<String, Object?>> _dialogueListFromRaw(Object? raw) {
    final decoded = raw is String && raw.trim().isNotEmpty
        ? jsonDecode(raw) as Object?
        : raw;
    if (decoded is! List) {
      return const [];
    }

    return [
      for (final item in decoded)
        if (item is Map)
          {for (final entry in item.entries) entry.key.toString(): entry.value},
    ];
  }

  List<DiscoverySentenceChunk> _chunksFromExample(
    String example, {
    required String languageLabel,
    required String targetWord,
  }) {
    final chunks = <DiscoverySentenceChunk>[
      DiscoverySentenceChunk(languageLabel, DiscoveryChipTone.language),
    ];
    final parts = example.split('**');

    for (var i = 0; i < parts.length; i++) {
      final text = _normalizeWhitespace(parts[i]);
      if (text.isEmpty) {
        continue;
      }

      final isMarked = i.isOdd;
      final tone = isMarked
          ? _toneForMarkedText(text, targetWord)
          : DiscoveryChipTone.context;
      chunks.add(DiscoverySentenceChunk(text, tone));
    }

    return chunks.length == 1
        ? [
            DiscoverySentenceChunk(languageLabel, DiscoveryChipTone.language),
            DiscoverySentenceChunk(example, DiscoveryChipTone.context),
          ]
        : chunks;
  }

  DiscoveryChipTone _toneForMarkedText(String text, String targetWord) {
    final normalizedText = text.trim().toLowerCase();
    final normalizedTarget = targetWord.trim().toLowerCase();
    final targetTerms = normalizedTarget
        .split(RegExp(r'\s+'))
        .where(
          (term) => term.length >= 2 && !_highlightStopWords.contains(term),
        );
    final containsTargetTerm = targetTerms.any(normalizedText.contains);

    return normalizedText == normalizedTarget ||
            normalizedTarget.contains(normalizedText) ||
            normalizedText.contains(normalizedTarget) ||
            containsTargetTerm
        ? DiscoveryChipTone.target
        : DiscoveryChipTone.action;
  }

  static const _highlightStopWords = {
    'a',
    'an',
    'the',
    'to',
    'of',
    'in',
    'on',
    'for',
    'l?m',
    'b?',
    's?',
    'c?',
    'm?t',
    'c?i',
    'con',
    'vi?c',
  };

  Alignment _alignmentFor(int order) {
    return switch (order) {
      1 => const Alignment(-1.0, -0.65),
      2 => const Alignment(1.0, -0.65),
      3 => const Alignment(1.0, 0.35),
      4 => const Alignment(0.0, 0.82),
      _ => const Alignment(-1.0, 0.35),
    };
  }

  String _stringValue(
    Map<String, Object?>? source,
    String key, {
    String fallback = '',
  }) {
    final value = source?[key];
    if (value == null) {
      return fallback;
    }
    final text = value.toString();
    return text.isEmpty ? fallback : text;
  }

  String _titleCase(String value) {
    final normalized = _cleanInlineMarkup(value).trim();
    if (normalized.isEmpty) {
      return 'Context';
    }
    return normalized
        .split(RegExp(r'\s+'))
        .map(
          (part) => part.isEmpty
              ? part
              : '${part[0].toUpperCase()}${part.substring(1)}',
        )
        .join(' ');
  }

  String _cleanInlineMarkup(String value) {
    return value.replaceAll('**', '');
  }

  String _normalizeWhitespace(String value) {
    // Collapse multiple spaces into one but preserve leading/trailing spaces â€”
    // they act as word separators between adjacent plain and highlighted spans.
    return value.replaceAll(RegExp(r'\s+'), ' ');
  }
}
