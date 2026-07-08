import 'package:flutter/material.dart';

import '../../../app/icons/kivo_icon_registry.dart';
import '../../../app/responsive/kivo_scale.dart';
import '../../../app/theme/kivo_theme_tokens.dart';
import '../view_model/review_view_state.dart';

class ReviewOptionGrid extends StatelessWidget {
  const ReviewOptionGrid({
    required this.question,
    required this.selectedOptionId,
    required this.onOptionSelected,
    super.key,
  });

  final ReviewQuestionData question;
  final String? selectedOptionId;
  final ValueChanged<ReviewAnswerOptionData> onOptionSelected;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: question.options.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: KivoScale.h(28),
        crossAxisSpacing: KivoScale.w(28),
        childAspectRatio: 1.28,
      ),
      itemBuilder: (context, index) {
        final option = question.options[index];
        final isSelected = selectedOptionId == option.id;
        final isCorrect = question.correctOptionId == option.id;
        final shouldReveal =
            selectedOptionId != null && (isSelected || isCorrect);

        return _AnswerOptionCard(
          option: option,
          isSelected: isSelected,
          isCorrect: isCorrect,
          shouldReveal: shouldReveal,
          isLocked: selectedOptionId != null,
          onTap: () => onOptionSelected(option),
        );
      },
    );
  }
}

class _AnswerOptionCard extends StatelessWidget {
  const _AnswerOptionCard({
    required this.option,
    required this.isSelected,
    required this.isCorrect,
    required this.shouldReveal,
    required this.isLocked,
    required this.onTap,
  });

  final ReviewAnswerOptionData option;
  final bool isSelected;
  final bool isCorrect;
  final bool shouldReveal;
  final bool isLocked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final didChooseWrong = isSelected && !isCorrect;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLocked ? null : onTap,
        borderRadius: BorderRadius.circular(KivoScale.r(26)),
        child: AnimatedContainer(
          duration: KivoDurations.fast,
          padding: EdgeInsets.symmetric(
            horizontal: KivoScale.w(18),
            vertical: KivoScale.h(22),
          ),
          decoration: BoxDecoration(
            color: _surfaceColor(didChooseWrong),
            borderRadius: BorderRadius.circular(KivoScale.r(26)),
            border: Border.all(
              color: _borderColor(didChooseWrong),
              width: isSelected || shouldReveal ? 2.4 : 1.4,
            ),
            boxShadow: isSelected || shouldReveal ? KivoShadows.soft : const [],
          ),
          child: Stack(
            children: [
              _OptionContent(option: option, shouldReveal: shouldReveal),
              if (shouldReveal) _RevealIcon(isCorrect: isCorrect),
            ],
          ),
        ),
      ),
    );
  }

  Color _borderColor(bool didChooseWrong) {
    if (shouldReveal && isCorrect) {
      return KivoColors.kivoTeal;
    }
    return didChooseWrong ? KivoColors.errorCoral : KivoColors.lightBorder;
  }

  Color _surfaceColor(bool didChooseWrong) {
    if (shouldReveal && isCorrect) {
      return KivoColors.softMintCard.withAlpha(168);
    }
    return didChooseWrong
        ? KivoColors.softPinkCard.withAlpha(160)
        : Colors.white.withAlpha(238);
  }
}

class _OptionContent extends StatelessWidget {
  const _OptionContent({required this.option, required this.shouldReveal});

  final ReviewAnswerOptionData option;
  final bool shouldReveal;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _OptionIcon(iconKey: option.iconKey),
          SizedBox(height: KivoScale.h(24)),
          Text(
            shouldReveal ? '${option.word} / ${option.meaning}' : option.word,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: KivoTextStyles.cardTitle.copyWith(
              color: KivoColors.inkText,
              fontSize: KivoScale.sp(28, min: 17),
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionIcon extends StatelessWidget {
  const _OptionIcon({required this.iconKey});

  final String iconKey;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: KivoScale.w(108),
      height: KivoScale.w(108),
      decoration: BoxDecoration(
        color: KivoColors.softMintCard,
        shape: BoxShape.circle,
      ),
      child: Icon(
        KivoIconRegistry.vocabulary(iconKey, tone: KivoIconTone.duotone),
        color: KivoColors.kivoTeal,
        size: KivoScale.w(58),
      ),
    );
  }
}

class _RevealIcon extends StatelessWidget {
  const _RevealIcon({required this.isCorrect});

  final bool isCorrect;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      right: 0,
      child: Icon(
        KivoIconRegistry.system(
          isCorrect ? 'success' : 'failed',
          tone: KivoIconTone.fill,
        ),
        color: isCorrect ? KivoColors.kivoTeal : KivoColors.errorCoral,
        size: KivoScale.w(46),
      ),
    );
  }
}
