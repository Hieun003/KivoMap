import 'package:flutter/material.dart';

import '../../../app/icons/kivo_icon_registry.dart';
import '../../../app/responsive/kivo_scale.dart';
import '../../../app/theme/kivo_theme_tokens.dart';
import '../view_model/discovery_view_state.dart';

class DiscoveryHeader extends StatelessWidget {
  const DiscoveryHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onBack,
  });

  final String title;
  final String subtitle;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: KivoScale.h(88).clamp(76, 100),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(left: 0, top: 0, child: _BackButton(onPressed: onBack)),
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: KivoScale.w(62)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: KivoTextStyles.display.copyWith(
                        fontSize: KivoScale.sp(34, min: 24),
                        color: KivoColors.coffeeText,
                        height: 1.04,
                      ),
                    ),
                  ),
                  SizedBox(height: KivoScale.h(4)),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: KivoTextStyles.cardTitle.copyWith(
                        color: KivoColors.inkText,
                        fontSize: KivoScale.sp(19, min: 15),
                        height: 1.08,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final size = KivoScale.w(54).clamp(46, 64).toDouble();

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(235),
          borderRadius: BorderRadius.circular(KivoScale.r(20)),
          border: Border.all(color: KivoColors.keywordOrange.withAlpha(70)),
          boxShadow: [
            BoxShadow(
              color: KivoColors.orangeShadow.withAlpha(56),
              blurRadius: KivoScale.r(12),
              offset: Offset(0, KivoScale.h(6)),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Icon(
          KivoIconRegistry.system('back', tone: KivoIconTone.bold),
          color: KivoColors.coffeeText,
          size: size * 0.46,
        ),
      ),
    );
  }
}

class TargetWordBanner extends StatelessWidget {
  const TargetWordBanner({super.key, required this.root});

  final DiscoveryRootNode root;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: constraints.maxWidth.clamp(0.0, 560.0),
            ),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: KivoScale.w(18),
                vertical: KivoScale.h(13),
              ),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(238),
                borderRadius: BorderRadius.circular(KivoScale.r(19)),
                border: Border.all(
                  color: KivoColors.targetPurple.withAlpha(112),
                ),
                boxShadow: KivoShadows.soft,
              ),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: KivoTextStyles.body.copyWith(
                    color: KivoColors.coffeeText,
                    fontSize: KivoScale.sp(16.5, min: 13),
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                  children: [
                    const TextSpan(
                      text: 'T\u1eeb v\u1ef1ng \u0111ang h\u1ecdc: ',
                    ),
                    TextSpan(
                      text: root.label.toUpperCase(),
                      style: KivoTextStyles.cardTitle.copyWith(
                        color: KivoColors.targetPurple,
                        fontSize: KivoScale.sp(22, min: 17),
                        fontWeight: FontWeight.w900,
                        height: 1.18,
                      ),
                    ),
                    if (root.translation.isNotEmpty)
                      TextSpan(text: ' (${root.translation})'),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class DiscoveryProgressBadge extends StatelessWidget {
  const DiscoveryProgressBadge({
    super.key,
    required this.understoodCount,
    required this.totalCount,
  });

  final int understoodCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: KivoScale.w(14),
          vertical: KivoScale.h(8),
        ),
        decoration: BoxDecoration(
          color: KivoColors.softMintCard.withAlpha(232),
          borderRadius: BorderRadius.circular(KivoScale.r(999)),
          border: Border.all(color: KivoColors.keywordGreen.withAlpha(150)),
          boxShadow: KivoShadows.soft,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              KivoIconRegistry.system('success', tone: KivoIconTone.fill),
              color: KivoColors.keywordGreen,
              size: KivoScale.w(18).clamp(15, 22),
            ),
            SizedBox(width: KivoScale.w(7)),
            Text(
              'Đã hiểu $understoodCount/$totalCount liên kết',
              style: KivoTextStyles.caption.copyWith(
                color: const Color(0xFF177B2D),
                fontSize: KivoScale.sp(13.5, min: 11.5),
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TapHint extends StatelessWidget {
  const TapHint({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: KivoScale.h(6)),
      child: Column(
        children: [
          Icon(
            KivoIconRegistry.system('pointing_hand', tone: KivoIconTone.fill),
            color: const Color(0xFFF5BE6D),
            size: KivoScale.w(30).clamp(26, 36),
          ),
          SizedBox(height: KivoScale.h(6)),
          Text(
            'Mở từng liên kết, rồi bấm "Đã hiểu"\nđể thắp sáng ma trận nhé!',
            textAlign: TextAlign.center,
            style: KivoTextStyles.body.copyWith(
              fontSize: KivoScale.sp(13.5, min: 11.5),
              fontWeight: FontWeight.w700,
              color: KivoColors.coffeeText,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
