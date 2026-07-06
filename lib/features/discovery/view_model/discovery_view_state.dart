import 'package:flutter/widgets.dart';

import '../../../app/theme/kivo_theme_tokens.dart';

enum DiscoveryContextStatus { discovered, available }

enum DiscoveryChipTone { language, action, target, context }

class DiscoveryMatrixState {
  const DiscoveryMatrixState({
    required this.clusterId,
    required this.vocabularyId,
    required this.nextVocabularyId,
    required this.nextVocabularyLabel,
    required this.title,
    required this.subtitle,
    required this.root,
    required this.contexts,
    required this.englishChunks,
    required this.vietnameseChunks,
  });

  final String clusterId;
  final String vocabularyId;
  final String? nextVocabularyId;
  final String? nextVocabularyLabel;
  final String title;
  final String subtitle;
  final DiscoveryRootNode root;
  final List<DiscoveryContextNode> contexts;
  final List<DiscoverySentenceChunk> englishChunks;
  final List<DiscoverySentenceChunk> vietnameseChunks;

  DiscoveryContextNode? get activeContext {
    for (final context in contexts) {
      if (context.status == DiscoveryContextStatus.discovered) {
        return context;
      }
    }
    return null;
  }

  DiscoveryContextNode? contextFor(String? contextId) {
    if (contextId == null) {
      return null;
    }

    for (final context in contexts) {
      if (context.id == contextId) {
        return context;
      }
    }
    return null;
  }
}

class DiscoveryRootNode {
  const DiscoveryRootNode({
    required this.label,
    required this.translation,
    required this.iconKey,
    required this.accentColor,
  });

  final String label;
  final String translation;
  final String iconKey;
  final Color accentColor;
}

class DiscoveryContextNode {
  const DiscoveryContextNode({
    required this.id,
    required this.order,
    required this.title,
    required this.translation,
    required this.iconKey,
    required this.alignment,
    required this.status,
    required this.sentence,
    required this.sentenceVi,
    required this.englishChunks,
    required this.vietnameseChunks,
    required this.dialogue,
    required this.tip,
  });

  final String id;
  final int order;
  final String title;
  final String translation;
  final String iconKey;
  final Alignment alignment;
  final DiscoveryContextStatus status;
  final String sentence;
  final String sentenceVi;
  final List<DiscoverySentenceChunk> englishChunks;
  final List<DiscoverySentenceChunk> vietnameseChunks;
  final List<DiscoveryDialogueLine> dialogue;
  final String tip;
  bool get isDiscovered => status == DiscoveryContextStatus.discovered;
}

class DiscoveryDialogueLine {
  const DiscoveryDialogueLine({
    required this.speaker,
    required this.text,
    required this.translation,
  });

  final String speaker;
  final String text;
  final String translation;
}

class DiscoverySentenceChunk {
  const DiscoverySentenceChunk(this.text, this.tone);

  final String text;
  final DiscoveryChipTone tone;
}

class DiscoveryChipPalette {
  const DiscoveryChipPalette({
    required this.text,
    required this.surface,
    required this.border,
    required this.shadow,
  });

  final Color text;
  final Color surface;
  final Color border;
  final Color shadow;

  static DiscoveryChipPalette fromTone(DiscoveryChipTone tone) {
    return switch (tone) {
      DiscoveryChipTone.language => const DiscoveryChipPalette(
        text: KivoColors.deepTeal,
        surface: KivoColors.softMintCard,
        border: KivoColors.kivoTeal,
        shadow: KivoColors.tealShadow,
      ),
      DiscoveryChipTone.action => const DiscoveryChipPalette(
        text: Color(0xFF9A3D02),
        surface: KivoColors.softOrangeCard,
        border: KivoColors.keywordOrange,
        shadow: KivoColors.orangeShadow,
      ),
      DiscoveryChipTone.target => const DiscoveryChipPalette(
        text: KivoColors.targetPurple,
        surface: Color(0xFFF1E9FF),
        border: Color(0xFFB99CFF),
        shadow: Color(0x557646FF),
      ),
      DiscoveryChipTone.context => const DiscoveryChipPalette(
        text: Color(0xFF0D5B20),
        surface: Color(0xFFF1FFE7),
        border: Color(0xFFA9D879),
        shadow: Color(0x446CCB4B),
      ),
    };
  }
}
