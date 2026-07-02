import 'package:flutter/material.dart';

import '../../../app/assets/image_paths.dart';
import '../../../app/icons/kivo_icon_registry.dart';
import '../../../app/responsive/kivo_scale.dart';
import '../../../app/theme/kivo_theme_tokens.dart';
import '../view_model/home_view_state.dart';

class HomeContextMapSection extends StatelessWidget {
  const HomeContextMapSection({
    super.key,
    required this.section,
    required this.onTopicSelected,
  });

  final HomeContextSectionData section;
  final ValueChanged<HomeContextTopicData> onTopicSelected;

  @override
  Widget build(BuildContext context) {
    final palette = _HomeAccentPalette.fromAccent(section.accentColor);

    return Padding(
      padding: EdgeInsets.only(top: KivoScale.h(4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _JourneyHeader(section: section, palette: palette),
          SizedBox(height: KivoScale.h(18)),
          Stack(
            children: [
              Positioned(
                left: KivoScale.w(52),
                top: KivoScale.h(24),
                bottom: KivoScale.h(24),
                child: Container(
                  width: KivoScale.w(3),
                  decoration: BoxDecoration(
                    color: palette.border.withAlpha(26),
                    borderRadius: BorderRadius.circular(KivoScale.r(999)),
                  ),
                ),
              ),
              Column(
                children: [
                  for (
                    var index = 0;
                    index < section.items.length;
                    index += 1
                  ) ...[
                    _ContextTopicTile(
                      item: section.items[index],
                      isOffset: index.isOdd,
                      onSelected: onTopicSelected,
                    ),
                    if (index != section.items.length - 1)
                      SizedBox(height: KivoScale.h(16)),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _JourneyHeader extends StatelessWidget {
  const _JourneyHeader({required this.section, required this.palette});

  final HomeContextSectionData section;
  final _HomeAccentPalette palette;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SectionIcon(iconKey: section.iconKey, palette: palette),
        SizedBox(width: KivoScale.w(14)),
        Expanded(
          child: Text(
            section.title,
            style: KivoTextStyles.sectionTitle.copyWith(
              color: palette.strong,
              fontSize: KivoScale.sp(30, min: 21),
              height: 1.05,
            ),
          ),
        ),
      ],
    );
  }
}

class _ContextTopicTile extends StatelessWidget {
  const _ContextTopicTile({
    required this.item,
    required this.isOffset,
    required this.onSelected,
  });

  final HomeContextTopicData item;
  final bool isOffset;
  final ValueChanged<HomeContextTopicData> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = _HomeAccentPalette.fromAccent(item.accentColor);

    return Padding(
      padding: EdgeInsets.only(left: isOffset ? KivoScale.w(18) : 0),
      child: GestureDetector(
        onTap: () => onSelected(item),
        child: Container(
          key: ValueKey('home-topic-${item.iconKey}'),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                palette.soft.withAlpha(210),
                Colors.white.withAlpha(238),
              ],
            ),
            borderRadius: BorderRadius.circular(KivoScale.r(24)),
            border: Border.all(color: palette.border.withAlpha(42), width: 0.9),
            boxShadow: [
              BoxShadow(
                color: KivoColors.shadow.withAlpha(10),
                blurRadius: KivoScale.r(14),
                offset: Offset(0, KivoScale.h(6)),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(
            horizontal: KivoScale.w(16),
            vertical: KivoScale.h(16),
          ),
          child: Row(
            children: [
              _TopicIllustration(iconKey: item.iconKey, palette: palette),
              SizedBox(width: KivoScale.w(20)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        text: item.title,
                        children: [
                          TextSpan(
                            text: '  ${item.subtitle}',
                            style: KivoTextStyles.body.copyWith(
                              color: KivoColors.inkText.withAlpha(198),
                              fontWeight: FontWeight.w600,
                              fontSize: KivoScale.sp(16, min: 12),
                            ),
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: KivoTextStyles.cardTitle.copyWith(
                        color: KivoColors.inkText,
                        fontSize: KivoScale.sp(20.5, min: 15),
                        height: 1.18,
                      ),
                    ),
                    SizedBox(height: KivoScale.h(12)),
                    _ProgressDots(
                      learnedCount: item.learnedCount,
                      totalCount: item.totalCount,
                      color: palette.strong,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressDots extends StatelessWidget {
  const _ProgressDots({
    required this.learnedCount,
    required this.totalCount,
    required this.color,
  });

  final int learnedCount;
  final int totalCount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: KivoScale.w(10),
      runSpacing: KivoScale.h(6),
      children: [
        for (var index = 0; index < totalCount; index += 1)
          Container(
            width: KivoScale.w(index < learnedCount ? 16 : 14),
            height: KivoScale.w(index < learnedCount ? 16 : 14),
            decoration: BoxDecoration(
              color: index < learnedCount ? color : Colors.white.withAlpha(210),
              shape: BoxShape.circle,
              border: Border.all(
                color: index < learnedCount ? color : KivoColors.disabledText,
                width: index < learnedCount ? 1.1 : 1.4,
              ),
            ),
          ),
      ],
    );
  }
}

class _SectionIcon extends StatelessWidget {
  const _SectionIcon({required this.iconKey, required this.palette});

  final String iconKey;
  final _HomeAccentPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: KivoScale.w(74),
      height: KivoScale.w(74),
      decoration: BoxDecoration(
        color: palette.soft,
        shape: BoxShape.circle,
        border: Border.all(color: palette.border.withAlpha(54), width: 1),
      ),
      alignment: Alignment.center,
      child: _ContextVisual(
        iconKey: iconKey,
        color: palette.strong,
        size: KivoScale.w(46),
        assetSize: KivoScale.w(58),
      ),
    );
  }
}

class _TopicIllustration extends StatelessWidget {
  const _TopicIllustration({required this.iconKey, required this.palette});

  final String iconKey;
  final _HomeAccentPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: KivoScale.w(108),
      height: KivoScale.w(108),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(195),
        borderRadius: BorderRadius.circular(KivoScale.r(22)),
        border: Border.all(color: palette.border.withAlpha(40), width: 0.9),
      ),
      alignment: Alignment.center,
      child: _ContextVisual(
        iconKey: iconKey,
        color: palette.strong,
        size: KivoScale.w(66),
        assetSize: KivoScale.w(92),
      ),
    );
  }
}

class _ContextVisual extends StatelessWidget {
  const _ContextVisual({
    required this.iconKey,
    required this.color,
    required this.size,
    required this.assetSize,
  });

  final String iconKey;
  final Color color;
  final double size;
  final double assetSize;

  @override
  Widget build(BuildContext context) {
    if (_isSecretPath(iconKey)) {
      return Image.asset(
        KivoImagePaths.mysteryStoneGate,
        width: assetSize,
        height: assetSize,
        fit: BoxFit.contain,
      );
    }

    return Icon(
      KivoIconRegistry.topic(iconKey, tone: KivoIconTone.fill),
      color: color,
      size: size,
    );
  }
}

bool _isSecretPath(String iconKey) {
  final normalizedKey = iconKey.trim().toLowerCase().replaceAll(
    RegExp(r'[\s-]+'),
    '_',
  );
  return normalizedKey == 'secret_path' || normalizedKey == 'secret_passage';
}

class _HomeAccentPalette {
  const _HomeAccentPalette({
    required this.strong,
    required this.soft,
    required this.border,
  });

  final Color strong;
  final Color soft;
  final Color border;

  static _HomeAccentPalette fromAccent(HomeAccentColor accent) {
    return switch (accent) {
      HomeAccentColor.blue => const _HomeAccentPalette(
        strong: KivoColors.keywordBlue,
        soft: KivoColors.softBlueCard,
        border: KivoColors.keywordBlue,
      ),
      HomeAccentColor.orange => const _HomeAccentPalette(
        strong: KivoColors.actionOrange,
        soft: KivoColors.softOrangeCard,
        border: KivoColors.keywordOrange,
      ),
      HomeAccentColor.pink => const _HomeAccentPalette(
        strong: KivoColors.errorCoral,
        soft: KivoColors.softPinkCard,
        border: KivoColors.errorCoral,
      ),
      HomeAccentColor.green => const _HomeAccentPalette(
        strong: KivoColors.successGreen,
        soft: KivoColors.softMintCard,
        border: KivoColors.successGreen,
      ),
      HomeAccentColor.purple => const _HomeAccentPalette(
        strong: KivoColors.targetPurple,
        soft: KivoColors.lightSurface,
        border: KivoColors.targetPurple,
      ),
    };
  }
}
