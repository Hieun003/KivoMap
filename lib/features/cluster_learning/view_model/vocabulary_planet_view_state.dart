import 'package:flutter/widgets.dart';

import '../../../app/theme/kivo_theme_tokens.dart';

enum VocabularyNodeStatus { learned, active, available }

enum VocabularyNodeAccent { teal, orange, pink, mint, neutral }

class VocabularyPlanetState {
  const VocabularyPlanetState({
    required this.clusterId,
    required this.title,
    required this.subtitle,
    required this.topicIconKey,
    required this.learnedCount,
    required this.totalCount,
    required this.nodes,
  });

  final String clusterId;
  final String title;
  final String subtitle;
  final String topicIconKey;
  final int learnedCount;
  final int totalCount;
  final List<VocabularyPlanetNodeData> nodes;

  double get progressRatio => totalCount == 0 ? 0 : learnedCount / totalCount;
}

class VocabularyPlanetNodeData {
  const VocabularyPlanetNodeData({
    required this.id,
    required this.label,
    required this.iconKey,
    required this.status,
    required this.accent,
    required this.alignment,
    required this.size,
  });

  final String id;
  final String label;
  final String iconKey;
  final VocabularyNodeStatus status;
  final VocabularyNodeAccent accent;
  final Alignment alignment;
  final double size;
}

class VocabularyNodePalette {
  const VocabularyNodePalette({
    required this.text,
    required this.surface,
    required this.border,
    required this.shadow,
    required this.rim,
  });

  final Color text;
  final Color surface;
  final Color border;
  final Color shadow;
  final Color rim;

  static VocabularyNodePalette fromNode(VocabularyPlanetNodeData node) {
    return switch (node.accent) {
      VocabularyNodeAccent.orange => const VocabularyNodePalette(
        text: Color(0xFF994A09),
        surface: KivoColors.softOrangeCard,
        border: Color(0xFFFFB25F),
        shadow: KivoColors.orangeShadow,
        rim: KivoColors.actionOrange,
      ),
      VocabularyNodeAccent.pink => const VocabularyNodePalette(
        text: Color(0xFF961B45),
        surface: KivoColors.softPinkCard,
        border: Color(0xFFFF96B6),
        shadow: Color(0x52FF6690),
        rim: KivoColors.errorCoral,
      ),
      VocabularyNodeAccent.mint ||
      VocabularyNodeAccent.teal => const VocabularyNodePalette(
        text: KivoColors.deepTeal,
        surface: KivoColors.softMintCard,
        border: Color(0xFF83E6D6),
        shadow: KivoColors.tealShadow,
        rim: KivoColors.kivoTeal,
      ),
      VocabularyNodeAccent.neutral => const VocabularyNodePalette(
        text: KivoColors.secondaryText,
        surface: Color(0xFFF9F8F5),
        border: Color(0xFFE2DED6),
        shadow: Color(0x4A7F7A72),
        rim: Color(0xFFC9C2B8),
      ),
    };
  }
}
