import 'package:flutter/material.dart';

import '../../../app/icons/kivo_icon_registry.dart';
import '../../../app/responsive/kivo_scale.dart';
import '../../../app/theme/kivo_theme_tokens.dart';
import '../view_model/discovery_view_state.dart';

class DiscoverySentencePlaceholder extends StatelessWidget {
  const DiscoverySentencePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            KivoScale.w(18),
            KivoScale.h(34),
            KivoScale.w(18),
            KivoScale.h(18),
          ),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(214),
            borderRadius: BorderRadius.circular(KivoScale.r(20)),
            border: Border.all(color: const Color(0xFFD7C7AD)),
            boxShadow: KivoShadows.soft,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ng\u1eef c\u1ea3nh \u0111ang ch\u1edd m\u1edf',
                style: KivoTextStyles.cardTitle.copyWith(
                  fontSize: KivoScale.sp(17, min: 14),
                  color: KivoColors.coffeeText,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: KivoScale.h(6)),
              Text(
                'B\u1ea5m m\u1ed9t li\u00ean k\u1ebft \u0111\u1ec3 xem c\u1ee5m di\u1ec5n \u0111\u1ea1t t\u1ef1 nhi\u00ean.',
                style: KivoTextStyles.body.copyWith(
                  fontSize: KivoScale.sp(14, min: 12),
                  color: KivoColors.inkText.withAlpha(190),
                  fontWeight: FontWeight.w600,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: KivoScale.w(12),
          top: -KivoScale.h(16),
          child: Container(
            width: KivoScale.w(36).clamp(32, 42),
            height: KivoScale.w(36).clamp(32, 42),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9EE),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFD7C7AD), width: 1.5),
              boxShadow: KivoShadows.soft,
            ),
            alignment: Alignment.center,
            child: Icon(
              KivoIconRegistry.system('dialogue', tone: KivoIconTone.fill),
              color: const Color(0xFFB4915C),
              size: KivoScale.w(20).clamp(16, 24),
            ),
          ),
        ),
      ],
    );
  }
}

class DiscoverySentencePanel extends StatelessWidget {
  const DiscoverySentencePanel({
    super.key,
    required this.englishChunks,
    required this.vietnameseChunks,
  });

  final List<DiscoverySentenceChunk> englishChunks;
  final List<DiscoverySentenceChunk> vietnameseChunks;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            KivoScale.w(18),
            KivoScale.h(36),
            KivoScale.w(16),
            KivoScale.h(16),
          ),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(226),
            borderRadius: BorderRadius.circular(KivoScale.r(20)),
            border: Border.all(color: const Color(0xFFE6B76D)),
            boxShadow: KivoShadows.soft,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SentenceRichText(chunks: englishChunks, isEnglish: true),
              Padding(
                padding: EdgeInsets.symmetric(vertical: KivoScale.h(10)),
                child: const _DashedDivider(color: Color(0xFFE6B76D)),
              ),
              _SentenceRichText(chunks: vietnameseChunks, isEnglish: false),
            ],
          ),
        ),
        Positioned(
          left: KivoScale.w(12),
          top: -KivoScale.h(16),
          child: Container(
            width: KivoScale.w(36).clamp(32, 42),
            height: KivoScale.w(36).clamp(32, 42),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9EE),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFF5BE6D), width: 1.5),
              boxShadow: KivoShadows.soft,
            ),
            alignment: Alignment.center,
            child: Icon(
              KivoIconRegistry.system('dialogue', tone: KivoIconTone.fill),
              color: const Color(0xFFE28B12),
              size: KivoScale.w(20).clamp(16, 24),
            ),
          ),
        ),
      ],
    );
  }
}

class _SentenceRichText extends StatelessWidget {
  const _SentenceRichText({required this.chunks, required this.isEnglish});

  final List<DiscoverySentenceChunk> chunks;
  final bool isEnglish;

  @override
  Widget build(BuildContext context) {
    final baseFontSize = KivoScale.sp(16.0, min: 14.0);
    final baseStyle = KivoTextStyles.body.copyWith(
      fontSize: baseFontSize,
      color: KivoColors.inkText,
      fontWeight: FontWeight.w600,
      height: 1.55,
    );

    // Language badge palette
    final langPalette = isEnglish
        ? DiscoveryChipPalette.fromTone(DiscoveryChipTone.context)
        : DiscoveryChipPalette.fromTone(DiscoveryChipTone.target);
    final langLabel = isEnglish ? 'EN' : 'VI';

    final spans = <InlineSpan>[
      // Language label as inline badge
      WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Container(
          margin: EdgeInsets.only(right: KivoScale.w(7)),
          padding: EdgeInsets.symmetric(
            horizontal: KivoScale.w(8),
            vertical: KivoScale.h(2.5),
          ),
          decoration: BoxDecoration(
            color: langPalette.surface,
            borderRadius: BorderRadius.circular(KivoScale.r(7)),
            border: Border.all(color: langPalette.border.withAlpha(190)),
          ),
          child: Text(
            langLabel,
            style: KivoTextStyles.cardTitle.copyWith(
              color: langPalette.text,
              fontSize: KivoScale.sp(11.5, min: 10.0),
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
        ),
      ),
    ];

    // Build inline text spans from chunks (skip the language chunk itself)
    for (final chunk in chunks) {
      if (chunk.tone == DiscoveryChipTone.language) continue;

      switch (chunk.tone) {
        case DiscoveryChipTone.target:
          // Target word: vibrant purple bold with subtle underline
          spans.add(
            TextSpan(
              text: chunk.text,
              style: baseStyle.copyWith(
                color: KivoColors.targetPurple,
                fontWeight: FontWeight.w800,
                decoration: TextDecoration.underline,
                decorationColor: KivoColors.targetPurple.withAlpha(160),
                decorationThickness: 2.0,
              ),
            ),
          );
        case DiscoveryChipTone.action:
          // Related keyword: orange bold
          spans.add(
            TextSpan(
              text: chunk.text,
              style: baseStyle.copyWith(
                color: const Color(0xFFB05200),
                fontWeight: FontWeight.w800,
              ),
            ),
          );
        default:
          // Plain context text — restore surrounding spaces
          spans.add(TextSpan(text: chunk.text, style: baseStyle));
      }
    }

    return RichText(text: TextSpan(children: spans));
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    const height = 1.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 5.0;
        const dashGap = 3.0;
        final dashCount = (boxWidth / (dashWidth + dashGap)).floor();
        return Flex(
          direction: Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: height,
              child: DecoratedBox(decoration: BoxDecoration(color: color)),
            );
          }),
        );
      },
    );
  }
}
