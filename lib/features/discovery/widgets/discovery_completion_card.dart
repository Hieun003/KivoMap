import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/icons/kivo_icon_registry.dart';
import '../../../app/responsive/kivo_scale.dart';
import '../../../app/theme/kivo_theme_tokens.dart';
import '../view_model/discovery_view_state.dart';

class DiscoveryCompletionCard extends StatelessWidget {
  const DiscoveryCompletionCard({
    super.key,
    required this.state,
    required this.onContinue,
  });

  final DiscoveryMatrixState state;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            KivoScale.w(18),
            KivoScale.h(22),
            KivoScale.w(18),
            KivoScale.h(20),
          ),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(236),
            borderRadius: BorderRadius.circular(KivoScale.r(24)),
            border: Border.all(color: const Color(0xFFE8C99F)),
            boxShadow: KivoShadows.raised,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: KivoScale.w(42).clamp(36, 48),
                    height: KivoScale.w(42).clamp(36, 48),
                    decoration: BoxDecoration(
                      color: KivoColors.softOrangeCard,
                      shape: BoxShape.circle,
                      border: Border.all(color: KivoColors.warningGold),
                      boxShadow: KivoShadows.orangeGlow,
                    ),
                    child: Icon(
                      KivoIconRegistry.reward('star', tone: KivoIconTone.fill),
                      color: const Color(0xFFFFB000),
                      size: KivoScale.w(25).clamp(20, 30),
                    ),
                  ),
                  SizedBox(width: KivoScale.w(12)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Xu\u1ea5t s\u1eafc! \u{1F389}',
                          style: KivoTextStyles.display.copyWith(
                            color: KivoColors.coffeeText,
                            fontSize: KivoScale.sp(30, min: 22),
                            height: 1.05,
                          ),
                        ),
                        SizedBox(height: KivoScale.h(8)),
                        RichText(
                          text: TextSpan(
                            style: KivoTextStyles.body.copyWith(
                              color: KivoColors.coffeeText,
                              fontSize: KivoScale.sp(15.5, min: 12.5),
                              fontWeight: FontWeight.w700,
                              height: 1.45,
                            ),
                            children: [
                              const TextSpan(
                                text:
                                    'B\u1ea3n \u0111\u1ed3 b\u1ed1i c\u1ea3nh c\u1ee7a ',
                              ),
                              TextSpan(
                                text: state.root.label,
                                style: const TextStyle(
                                  color: KivoColors.targetPurple,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const TextSpan(
                                text:
                                    ' \u0111\u00e3 \u0111\u01b0\u1ee3c th\u1eafp s\u00e1ng ho\u00e0n to\u00e0n!\nC\u00f9ng duy tr\u00ec \u0111\u00e0 chi\u1ebfn th\u1eafng n\u00e0y nh\u00e9! \u{1F525}',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: KivoScale.w(86).clamp(70, 104),
                    height: KivoScale.h(72).clamp(56, 86),
                    child: CustomPaint(
                      painter: const _MiniCelebrationPainter(),
                    ),
                  ),
                ],
              ),
              SizedBox(height: KivoScale.h(20)),
              _DiscoveryContinueButton(
                label: state.nextVocabularyLabel == null
                    ? 'Tr\u1edf l\u1ea1i H\u00e0nh tinh t\u1eeb v\u1ef1ng \u{1FA90}'
                    : 'Kh\u00e1m ph\u00e1 ti\u1ebfp: ${state.nextVocabularyLabel}',
                onPressed: onContinue,
                isFullWidth: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DiscoveryContinueButton extends StatelessWidget {
  const _DiscoveryContinueButton({
    required this.label,
    required this.onPressed,
    this.isFullWidth = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isFullWidth;

  @override
  Widget build(BuildContext context) {
    final button = Container(
      width: isFullWidth ? double.infinity : null,
      constraints: isFullWidth
          ? null
          : BoxConstraints(maxWidth: KivoScale.w(300).clamp(240, 340)),
      padding: EdgeInsets.symmetric(
        horizontal: KivoScale.w(22),
        vertical: KivoScale.h(13),
      ),
      decoration: BoxDecoration(
        gradient: KivoGradients.orangeButton,
        borderRadius: BorderRadius.circular(KivoScale.r(28)),
        border: Border.all(color: const Color(0xFFFFB14D), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD95300).withAlpha(190),
            blurRadius: KivoScale.r(0),
            offset: Offset(0, KivoScale.h(7)),
          ),
          ...KivoShadows.orangeGlow,
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: KivoTextStyles.cta.copyWith(
                fontSize: KivoScale.sp(24, min: 18),
                shadows: const [
                  Shadow(color: Color(0x663A1608), offset: Offset(0, 2)),
                ],
              ),
            ),
          ),
          SizedBox(width: KivoScale.w(12)),
          Icon(
            Icons.arrow_forward_rounded,
            color: Colors.white,
            size: KivoScale.w(28).clamp(22, 34),
          ),
        ],
      ),
    );

    return isFullWidth
        ? GestureDetector(onTap: onPressed, child: button)
        : Center(
            child: GestureDetector(onTap: onPressed, child: button),
          );
  }
}

class _MiniCelebrationPainter extends CustomPainter {
  const _MiniCelebrationPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.shortestSide * 0.06;
    const colors = [
      Color(0xFFFF96B6),
      Color(0xFFFFD966),
      Color(0xFF65D6FF),
      Color(0xFFA7E66E),
      Color(0xFFC899FF),
    ];

    for (var i = 0; i < 12; i += 1) {
      final angle = -math.pi * 0.9 + i * math.pi / 6;
      final start = Offset(size.width * 0.52, size.height * 0.72);
      final end =
          start +
          Offset(math.cos(angle), math.sin(angle)) *
              size.shortestSide *
              (0.28 + (i % 3) * 0.08);
      paint.color = colors[i % colors.length];
      canvas.drawLine(start, end, paint);
    }

    final dotPaint = Paint()..style = PaintingStyle.fill;
    for (var i = 0; i < 14; i += 1) {
      dotPaint.color = colors[(i + 2) % colors.length];
      final x = size.width * (0.12 + (i % 5) * 0.18);
      final y = size.height * (0.16 + (i % 4) * 0.16);
      canvas.drawCircle(Offset(x, y), size.shortestSide * 0.028, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _MiniCelebrationPainter oldDelegate) => false;
}
