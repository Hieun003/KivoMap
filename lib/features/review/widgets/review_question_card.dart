import 'package:flutter/material.dart';

import '../../../app/responsive/kivo_scale.dart';
import '../../../app/theme/kivo_theme_tokens.dart';
import '../view_model/review_view_state.dart';

class ReviewQuestionCard extends StatelessWidget {
  const ReviewQuestionCard({required this.question, super.key});

  final ReviewQuestionData question;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: KivoScale.h(520)),
      padding: EdgeInsets.symmetric(
        horizontal: KivoScale.w(54),
        vertical: KivoScale.h(64),
      ),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(238),
        borderRadius: BorderRadius.circular(KivoScale.r(44)),
        border: Border.all(color: KivoColors.glowMint, width: KivoScale.w(4)),
        boxShadow: [
          BoxShadow(
            color: KivoColors.tealShadow.withAlpha(130),
            blurRadius: KivoScale.r(34),
            spreadRadius: KivoScale.r(1),
          ),
        ],
      ),
      child: Center(
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(children: _sentenceSpans()),
        ),
      ),
    );
  }

  List<InlineSpan> _sentenceSpans() {
    final spans = <InlineSpan>[];
    for (final segment in question.segments) {
      final baseStyle = _segmentStyle(segment);
      if (!segment.text.contains('[ ? ]')) {
        spans.add(TextSpan(text: segment.text, style: baseStyle));
        continue;
      }

      spans.addAll(_blankSpans(segment.text, baseStyle));
    }
    return spans;
  }

  TextStyle _segmentStyle(ReviewSentenceSegment segment) {
    return KivoTextStyles.screenTitle.copyWith(
      color: KivoColors.inkText,
      fontSize: KivoScale.sp(54, min: 30),
      height: 1.55,
      fontWeight: segment.isHighlighted ? FontWeight.w900 : FontWeight.w800,
    );
  }

  List<InlineSpan> _blankSpans(String text, TextStyle baseStyle) {
    final spans = <InlineSpan>[];
    final parts = text.split('[ ? ]');
    for (var i = 0; i < parts.length; i++) {
      if (parts[i].isNotEmpty) {
        spans.add(TextSpan(text: parts[i], style: baseStyle));
      }
      if (i < parts.length - 1) {
        spans.add(
          const WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: _QuestionBlank(),
          ),
        );
      }
    }
    return spans;
  }
}

class _QuestionBlank extends StatelessWidget {
  const _QuestionBlank();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: KivoScale.w(10)),
      padding: EdgeInsets.symmetric(
        horizontal: KivoScale.w(44),
        vertical: KivoScale.h(12),
      ),
      decoration: BoxDecoration(
        color: KivoColors.softBlueCard.withAlpha(190),
        borderRadius: BorderRadius.circular(KivoScale.r(20)),
        border: Border.all(color: KivoColors.actionCyan, width: 2),
        boxShadow: [
          BoxShadow(
            color: KivoColors.actionCyan.withAlpha(80),
            blurRadius: KivoScale.r(18),
          ),
        ],
      ),
      child: Text(
        '[ ? ]',
        style: KivoTextStyles.screenTitle.copyWith(
          color: KivoColors.actionCyan,
          fontSize: KivoScale.sp(45, min: 26),
          height: 1,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
