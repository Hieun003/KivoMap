import 'package:flutter/material.dart';

import '../../../app/assets/image_paths.dart';
import '../../../app/icons/kivo_icon_registry.dart';
import '../../../app/responsive/kivo_scale.dart';
import '../../../app/theme/kivo_theme_tokens.dart';
import '../view_model/vocabulary_planet_view_state.dart';

class VocabularyPlanetSummaryCard extends StatelessWidget {
  const VocabularyPlanetSummaryCard({super.key, required this.state});

  final VocabularyPlanetState state;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 390;
        final cardHeight = KivoScale.h(
          isCompact ? 112 : 132,
        ).clamp(112, 142).toDouble();
        final mascotSize = (constraints.maxWidth * 0.22).clamp(76.0, 108.0);
        final iconSize = (constraints.maxWidth * 0.18).clamp(62.0, 88.0);

        return Container(
          width: double.infinity,
          height: cardHeight,
          padding: EdgeInsets.symmetric(
            horizontal: KivoScale.w(isCompact ? 12 : 18),
          ),
          decoration: BoxDecoration(
            gradient: KivoGradients.mintCard,
            borderRadius: BorderRadius.circular(KivoScale.r(22)),
            border: Border.all(
              color: KivoColors.kivoTeal.withAlpha(78),
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: KivoColors.tealShadow.withAlpha(45),
                blurRadius: KivoScale.r(16),
                offset: Offset(0, KivoScale.h(7)),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 30,
                child: Align(
                  alignment: Alignment.center,
                  child: Image.asset(
                    KivoImagePaths.kivoLogin,
                    width: mascotSize,
                    height: mascotSize,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Expanded(
                flex: 24,
                child: Align(
                  alignment: Alignment.center,
                  child: _TopicMedallion(
                    iconKey: state.topicIconKey,
                    size: iconSize,
                  ),
                ),
              ),
              Expanded(
                flex: 46,
                child: Align(
                  alignment: Alignment.center,
                  child: _ProgressSummary(
                    learnedCount: state.learnedCount,
                    totalCount: state.totalCount,
                    isCompact: isCompact,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TopicMedallion extends StatelessWidget {
  const _TopicMedallion({required this.iconKey, required this.size});

  final String iconKey;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(150),
        borderRadius: BorderRadius.circular(KivoScale.r(16)),
        border: Border.all(color: KivoColors.kivoTeal.withAlpha(78)),
        boxShadow: [
          BoxShadow(
            color: KivoColors.tealShadow.withAlpha(35),
            blurRadius: KivoScale.r(10),
            offset: Offset(0, KivoScale.h(5)),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Icon(
        KivoIconRegistry.topic(iconKey, tone: KivoIconTone.fill),
        size: size * 0.58,
        color: KivoColors.keywordBlue,
      ),
    );
  }
}

class _ProgressSummary extends StatelessWidget {
  const _ProgressSummary({
    required this.learnedCount,
    required this.totalCount,
    required this.isCompact,
  });

  final int learnedCount;
  final int totalCount;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: KivoScale.w(160).clamp(128, 176)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              'Đã học:',
              style: KivoTextStyles.cardTitle.copyWith(
                color: KivoColors.deepTeal,
                fontSize: KivoScale.sp(isCompact ? 18 : 20, min: 14),
                height: 1.02,
              ),
            ),
          ),
          SizedBox(height: KivoScale.h(4)),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              '$learnedCount / $totalCount',
              style: KivoTextStyles.display.copyWith(
                color: KivoColors.deepTeal,
                fontSize: KivoScale.sp(isCompact ? 40 : 47, min: 30),
                height: 0.92,
              ),
            ),
          ),
          SizedBox(height: KivoScale.h(3)),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              'Từ vựng',
              style: KivoTextStyles.cardTitle.copyWith(
                color: KivoColors.deepTeal.withAlpha(220),
                fontSize: KivoScale.sp(isCompact ? 18 : 20, min: 14),
                height: 1.02,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
