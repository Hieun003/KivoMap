import 'package:flutter/widgets.dart';

import '../../../app/theme/kivo_theme_tokens.dart';

enum VocabularyNodeStatus { learned, active, locked }

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

  static const VocabularyPlanetState airportCheckIn = VocabularyPlanetState(
    clusterId: 'cluster_airport_checkin',
    title: 'Thủ tục Sân Bay',
    subtitle: '(Airport Check-in)',
    topicIconKey: 'airport_check_in',
    learnedCount: 2,
    totalCount: 5,
    nodes: [
      VocabularyPlanetNodeData(
        id: 'vocab_passport',
        label: 'Passport',
        iconKey: 'passport',
        status: VocabularyNodeStatus.learned,
        accent: VocabularyNodeAccent.teal,
        alignment: Alignment(0.0, -0.72),
        size: 132,
      ),
      VocabularyPlanetNodeData(
        id: 'vocab_luggage',
        label: 'Luggage',
        iconKey: 'luggage',
        status: VocabularyNodeStatus.learned,
        accent: VocabularyNodeAccent.teal,
        alignment: Alignment(0.68, -0.22),
        size: 132,
      ),
      VocabularyPlanetNodeData(
        id: 'vocab_security',
        label: 'Security',
        iconKey: 'security_check',
        status: VocabularyNodeStatus.active,
        accent: VocabularyNodeAccent.orange,
        alignment: Alignment(0.0, 0.22),
        size: 128,
      ),
      VocabularyPlanetNodeData(
        id: 'vocab_boarding_pass',
        label: 'Boarding\nPass',
        iconKey: 'boarding_pass',
        status: VocabularyNodeStatus.locked,
        accent: VocabularyNodeAccent.neutral,
        alignment: Alignment(-0.68, -0.22),
        size: 128,
      ),
      VocabularyPlanetNodeData(
        id: 'vocab_counter',
        label: 'Counter',
        iconKey: 'counter',
        status: VocabularyNodeStatus.locked,
        accent: VocabularyNodeAccent.neutral,
        alignment: Alignment(-0.42, 0.58),
        size: 122,
      ),
    ],
  );
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
    if (node.status == VocabularyNodeStatus.locked) {
      return const VocabularyNodePalette(
        text: KivoColors.secondaryText,
        surface: Color(0xFFF9F8F5),
        border: Color(0xFFE2DED6),
        shadow: Color(0x4A7F7A72),
        rim: Color(0xFFC9C2B8),
      );
    }

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
