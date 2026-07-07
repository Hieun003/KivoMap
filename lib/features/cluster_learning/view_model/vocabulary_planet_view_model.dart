import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../data/kivo_seed_data.dart';
import 'vocabulary_planet_view_state.dart';

const int _requiredContextsForSrs = 3;

const Map<String, Map<String, Object>> _mockRepetitionStates = {
  'vocab_spill': {'masteryLevel': 4, 'isDue': false},
  'vocab_barista': {'masteryLevel': 2, 'isDue': true},
};

const Map<String, int> _mockDiscoveredContextCounts = {'vocab_takeaway': 2};

class VocabularyPlanetViewModel extends GetxController {
  final RxBool isLoading = true.obs;
  final RxnString errorMessage = RxnString();
  final Rxn<VocabularyPlanetState> state = Rxn<VocabularyPlanetState>();

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
      final clusterId = args is Map ? args['clusterId'] as String? : null;
      state.value = _stateFromSeed(clusterId);
    } catch (_) {
      errorMessage.value =
          'Kh\u00f4ng th\u1ec3 m\u1edf h\u00e0nh tinh t\u1eeb v\u1ef1ng. H\u00e3y th\u1eed l\u1ea1i nh\u00e9.';
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Future<void> refresh() => load();

  void goBack() {
    Get.back<void>();
  }

  void selectNode(VocabularyPlanetNodeData node) {
    Get.toNamed(
      AppRoutes.discoveryMatrix,
      arguments: {'clusterId': state.value?.clusterId, 'vocabularyId': node.id},
    );
  }

  VocabularyPlanetState _stateFromSeed(String? clusterId) {
    final cluster = _findCluster(clusterId);
    final resolvedClusterId = _stringValue(cluster, 'id');
    final vocabularies = seedVocabularies
        .where(
          (vocabulary) =>
              _stringValue(vocabulary, 'clusterId') == resolvedClusterId &&
              vocabulary['isPlanet'] != false,
        )
        .toList(growable: false);
    final nodes = [
      for (var i = 0; i < vocabularies.length; i++)
        _nodeFromVocabulary(vocabularies[i], i),
    ];
    final learnedCount = nodes.where((node) => node.isInSrs).length;

    return VocabularyPlanetState(
      clusterId: resolvedClusterId,
      title: _stringValue(
        cluster,
        'titleVi',
        fallback: _stringValue(cluster, 'title'),
      ),
      subtitle: '(${_stringValue(cluster, 'title')})',
      topicIconKey: _stringValue(cluster, 'iconKey', fallback: 'default'),
      learnedCount: learnedCount,
      totalCount: vocabularies.length,
      nodes: nodes,
    );
  }

  VocabularyPlanetNodeData _nodeFromVocabulary(
    Map<String, Object?> vocabulary,
    int index,
  ) {
    final vocabularyId = _stringValue(vocabulary, 'id');

    return VocabularyPlanetNodeData(
      id: vocabularyId,
      label: _nodeLabel(_stringValue(vocabulary, 'word')),
      iconKey: _stringValue(vocabulary, 'iconKey', fallback: 'default'),
      status: _statusForVocabulary(vocabularyId),
      accent: _accentForIndex(index),
      alignment: _alignmentForIndex(index),
      size: _sizeForIndex(index),
    );
  }

  Map<dynamic, dynamic> _findCluster(String? clusterId) {
    if (clusterId != null) {
      for (final cluster in seedClusters) {
        if (_stringValue(cluster, 'id') == clusterId) {
          return cluster;
        }
      }
    }
    return seedClusters.first;
  }

  VocabularyNodeStatus _statusForVocabulary(String vocabularyId) {
    final repetitionState = _mockRepetitionStates[vocabularyId];
    if (repetitionState != null) {
      final masteryLevel =
          (repetitionState['masteryLevel'] as num?)?.toInt() ?? 1;
      final isDue = repetitionState['isDue'] == true;

      if (masteryLevel >= 10) {
        return VocabularyNodeStatus.mastered;
      }
      if (isDue) {
        return VocabularyNodeStatus.reviewDue;
      }
      return VocabularyNodeStatus.srsActive;
    }

    final discoveredCount = _mockDiscoveredContextCounts[vocabularyId] ?? 0;
    if (discoveredCount > 0 && discoveredCount < _requiredContextsForSrs) {
      return VocabularyNodeStatus.inProgress;
    }

    return VocabularyNodeStatus.notStarted;
  }

  VocabularyNodeAccent _accentForIndex(int index) {
    return switch (index % 4) {
      0 => VocabularyNodeAccent.teal,
      1 => VocabularyNodeAccent.mint,
      2 => VocabularyNodeAccent.orange,
      _ => VocabularyNodeAccent.pink,
    };
  }

  Alignment _alignmentForIndex(int index) {
    const positions = <Alignment>[
      Alignment(0.0, -0.72),
      Alignment(0.68, -0.22),
      Alignment(0.0, 0.22),
      Alignment(-0.68, -0.22),
      Alignment(-0.42, 0.58),
      Alignment(0.52, 0.62),
    ];
    return positions[index % positions.length];
  }

  double _sizeForIndex(int index) {
    return switch (index % 3) {
      0 => 132,
      1 => 128,
      _ => 122,
    };
  }

  String _nodeLabel(String word) {
    final title = _titleCase(word);
    final parts = title.split(' ');
    if (parts.length <= 1) {
      return title;
    }
    final midpoint = (parts.length / 2).ceil();
    return '${parts.take(midpoint).join(' ')}\n${parts.skip(midpoint).join(' ')}';
  }

  String _stringValue(
    Map<dynamic, dynamic> source,
    String key, {
    String fallback = '',
  }) {
    final value = source[key];
    if (value == null) {
      return fallback;
    }
    final text = value.toString();
    return text.isEmpty ? fallback : text;
  }

  String _titleCase(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized.isEmpty) {
      return 'Word';
    }
    return normalized
        .split(RegExp(r'[_\s-]+'))
        .map(
          (part) => part.isEmpty
              ? part
              : '${part[0].toUpperCase()}${part.substring(1)}',
        )
        .join(' ');
  }
}

extension on VocabularyPlanetNodeData {
  bool get isInSrs {
    return switch (status) {
      VocabularyNodeStatus.srsActive ||
      VocabularyNodeStatus.reviewDue ||
      VocabularyNodeStatus.mastered => true,
      _ => false,
    };
  }
}
