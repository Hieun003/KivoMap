import 'package:flutter/material.dart';

import '../../../app/icons/kivo_icon_registry.dart';
import '../../../app/responsive/kivo_scale.dart';
import '../../../app/theme/kivo_theme_tokens.dart';
import '../view_model/discovery_view_state.dart';
import 'deep_dialogue_bubble.dart';
import 'practical_tip_card.dart';

class DiscoveryContextBottomSheet extends StatelessWidget {
  const DiscoveryContextBottomSheet({
    super.key,
    required this.rootNode,
    required this.contextNode,
    required this.onUnderstood,
  });

  final DiscoveryRootNode rootNode;
  final DiscoveryContextNode contextNode;
  final VoidCallback onUnderstood;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final panelHeight = screenHeight * 0.88;
    final keywords = _deepContextKeywords;

    return SafeArea(
      top: false,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: panelHeight,
          width: double.infinity,
          margin: EdgeInsets.only(top: KivoScale.h(24)),
          decoration: BoxDecoration(
            color: KivoColors.lightSurface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(KivoScale.r(28)),
            ),
            boxShadow: KivoShadows.raised,
          ),
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  KivoScale.w(22),
                  KivoScale.h(22),
                  KivoScale.w(22),
                  KivoScale.h(26),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(child: const _SheetHandle()),
                    SizedBox(height: KivoScale.h(18)),
                    _DeepContextHeader(
                      rootNode: rootNode,
                      contextNode: contextNode,
                    ),
                    SizedBox(height: KivoScale.h(22)),
                    _DeepContextLearningStack(
                      rootNode: rootNode,
                      contextNode: contextNode,
                    ),
                    SizedBox(height: KivoScale.h(18)),
                    for (var i = 0; i < contextNode.dialogue.length; i += 1)
                      DeepDialogueBubble(
                        line: contextNode.dialogue[i],
                        alignRight: i.isOdd,
                        keywords: keywords,
                      ),
                    if (contextNode.dialogue.isEmpty)
                      DeepDialogueBubble(
                        line: DiscoveryDialogueLine(
                          speaker: contextNode.title,
                          text: contextNode.sentence,
                          translation: contextNode.sentenceVi,
                        ),
                        alignRight: false,
                        keywords: keywords,
                      ),
                    SizedBox(height: KivoScale.h(6)),
                    PracticalTipCard(tip: contextNode.tip, keywords: keywords),
                    SizedBox(height: KivoScale.h(18)),
                    _UnderstoodButton(onPressed: onUnderstood),
                  ],
                ),
              ),
              Positioned(
                right: KivoScale.w(18),
                top: KivoScale.h(44),
                child: _DeepContextCloseButton(
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<String> get _deepContextKeywords {
    return {
      rootNode.label,
      rootNode.translation,
      contextNode.title,
      contextNode.translation,
      for (final chunk in contextNode.englishChunks)
        if (chunk.tone == DiscoveryChipTone.target ||
            chunk.tone == DiscoveryChipTone.action)
          chunk.text.trim(),
      for (final chunk in contextNode.vietnameseChunks)
        if (chunk.tone == DiscoveryChipTone.target ||
            chunk.tone == DiscoveryChipTone.action)
          chunk.text.trim(),
    }.where((keyword) => keyword.isNotEmpty).toList(growable: false);
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: KivoScale.w(46).clamp(38, 56),
      height: KivoScale.h(5).clamp(4, 6),
      decoration: BoxDecoration(
        color: const Color(0xFFD8C8B7),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _DeepContextHeader extends StatelessWidget {
  const _DeepContextHeader({required this.rootNode, required this.contextNode});

  final DiscoveryRootNode rootNode;
  final DiscoveryContextNode contextNode;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: KivoScale.w(96).clamp(78, 118),
          height: KivoScale.w(96).clamp(78, 118),
          decoration: BoxDecoration(
            color: KivoColors.softOrangeCard,
            borderRadius: BorderRadius.circular(KivoScale.r(22)),
            border: Border.all(color: KivoColors.keywordOrange.withAlpha(140)),
            boxShadow: KivoShadows.soft,
          ),
          child: Icon(
            KivoIconRegistry.vocabulary(
              contextNode.iconKey,
              tone: KivoIconTone.duotone,
            ),
            color: KivoColors.actionOrange,
            size: KivoScale.w(52).clamp(42, 64),
          ),
        ),
        SizedBox(width: KivoScale.w(16)),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: KivoScale.w(52)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    style: KivoTextStyles.body.copyWith(
                      color: KivoColors.coffeeText,
                      fontSize: KivoScale.sp(14.5, min: 12),
                      fontWeight: FontWeight.w700,
                    ),
                    children: [
                      const TextSpan(
                        text: 'T\u1eeb kh\u00f3a c\u1ed1t l\u00f5i: ',
                      ),
                      TextSpan(
                        text: rootNode.label,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: KivoScale.h(8)),
                Text(
                  contextNode.translation.isEmpty
                      ? contextNode.title
                      : '${contextNode.title} (${contextNode.translation})',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: KivoTextStyles.display.copyWith(
                    color: KivoColors.coffeeText,
                    fontSize: KivoScale.sp(27, min: 20),
                    height: 1.08,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DeepContextCloseButton extends StatelessWidget {
  const _DeepContextCloseButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: KivoScale.w(46).clamp(40, 54),
        height: KivoScale.w(46).clamp(40, 54),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(242),
          borderRadius: BorderRadius.circular(KivoScale.r(16)),
          border: Border.all(color: KivoColors.lightBorder),
          boxShadow: KivoShadows.soft,
        ),
        child: Icon(
          KivoIconRegistry.system('close', tone: KivoIconTone.bold),
          color: KivoColors.coffeeText,
          size: KivoScale.w(26).clamp(22, 32),
        ),
      ),
    );
  }
}

class _DeepContextLearningStack extends StatelessWidget {
  const _DeepContextLearningStack({
    required this.rootNode,
    required this.contextNode,
  });

  final DiscoveryRootNode rootNode;
  final DiscoveryContextNode contextNode;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _EnglishContextBlock(chunks: contextNode.englishChunks),
        SizedBox(height: KivoScale.h(12)),
        _MiniVocabCardRow(rootNode: rootNode, contextNode: contextNode),
        SizedBox(height: KivoScale.h(12)),
        _VietnameseContextBlock(text: contextNode.sentenceVi),
      ],
    );
  }
}

class _EnglishContextBlock extends StatelessWidget {
  const _EnglishContextBlock({required this.chunks});

  final List<DiscoverySentenceChunk> chunks;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(KivoScale.w(16)),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(238),
        borderRadius: BorderRadius.circular(KivoScale.r(18)),
        border: Border.all(color: const Color(0xFFE4D7C9)),
        boxShadow: KivoShadows.soft,
      ),
      child: _ContextChunkRichText(
        chunks: chunks,
        fontSize: KivoScale.sp(16, min: 13),
      ),
    );
  }
}

class _ContextChunkRichText extends StatelessWidget {
  const _ContextChunkRichText({required this.chunks, required this.fontSize});

  final List<DiscoverySentenceChunk> chunks;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final baseStyle = KivoTextStyles.body.copyWith(
      color: KivoColors.inkText,
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      height: 1.48,
    );

    return RichText(
      text: TextSpan(
        children: [
          for (final chunk in chunks)
            if (chunk.tone != DiscoveryChipTone.language)
              TextSpan(
                text: chunk.text,
                style: baseStyle.copyWith(
                  color: switch (chunk.tone) {
                    DiscoveryChipTone.target => KivoColors.targetPurple,
                    DiscoveryChipTone.action => const Color(0xFFB05200),
                    _ => KivoColors.inkText,
                  },
                  fontWeight: chunk.tone == DiscoveryChipTone.context
                      ? FontWeight.w600
                      : FontWeight.w900,
                ),
              ),
        ],
      ),
    );
  }
}

class _MiniVocabCardRow extends StatelessWidget {
  const _MiniVocabCardRow({required this.rootNode, required this.contextNode});

  final DiscoveryRootNode rootNode;
  final DiscoveryContextNode contextNode;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = ((constraints.maxWidth - KivoScale.w(10)) / 2)
            .clamp(128.0, 220.0)
            .toDouble();

        return Wrap(
          spacing: KivoScale.w(10),
          runSpacing: KivoScale.h(10),
          alignment: WrapAlignment.center,
          children: [
            _MiniVocabCard(
              width: cardWidth,
              label: rootNode.label,
              meaning: rootNode.translation,
              tone: DiscoveryChipTone.target,
            ),
            _MiniVocabCard(
              width: cardWidth,
              label: contextNode.title,
              meaning: contextNode.translation,
              tone: DiscoveryChipTone.action,
            ),
          ],
        );
      },
    );
  }
}

class _MiniVocabCard extends StatelessWidget {
  const _MiniVocabCard({
    required this.width,
    required this.label,
    required this.meaning,
    required this.tone,
  });

  final double width;
  final String label;
  final String meaning;
  final DiscoveryChipTone tone;

  @override
  Widget build(BuildContext context) {
    final palette = DiscoveryChipPalette.fromTone(tone);

    return Container(
      width: width,
      padding: EdgeInsets.symmetric(
        horizontal: KivoScale.w(12),
        vertical: KivoScale.h(10),
      ),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(KivoScale.r(12)),
        border: Border.all(color: palette.border.withAlpha(210)),
        boxShadow: [
          BoxShadow(
            color: palette.shadow.withAlpha(36),
            blurRadius: KivoScale.r(10),
            offset: Offset(0, KivoScale.h(4)),
          ),
        ],
      ),
      child: Text(
        meaning.isEmpty ? label : '$label = $meaning',
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: KivoTextStyles.body.copyWith(
          color: palette.text,
          fontSize: KivoScale.sp(13.5, min: 11),
          fontWeight: FontWeight.w900,
          height: 1.2,
        ),
      ),
    );
  }
}

class _VietnameseContextBlock extends StatelessWidget {
  const _VietnameseContextBlock({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: KivoTextStyles.body.copyWith(
        color: KivoColors.secondaryText,
        fontSize: KivoScale.sp(14.5, min: 12),
        fontWeight: FontWeight.w600,
        height: 1.42,
      ),
    );
  }
}

class _UnderstoodButton extends StatelessWidget {
  const _UnderstoodButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: KivoScale.h(14)),
        decoration: BoxDecoration(
          gradient: KivoGradients.orangeButton,
          borderRadius: BorderRadius.circular(KivoScale.r(25)),
          border: Border.all(color: const Color(0xFFFFB14D), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD95300).withAlpha(190),
              blurRadius: 0,
              offset: Offset(0, KivoScale.h(7)),
            ),
            ...KivoShadows.orangeGlow,
          ],
        ),
        child: Text(
          'Đã hiểu liên kết này \u{1F44D}',
          textAlign: TextAlign.center,
          style: KivoTextStyles.cta.copyWith(
            fontSize: KivoScale.sp(26, min: 20),
            shadows: const [
              Shadow(color: Color(0x663A1608), offset: Offset(0, 2)),
            ],
          ),
        ),
      ),
    );
  }
}
