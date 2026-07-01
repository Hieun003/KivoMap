import 'package:flutter/material.dart';

import '../../../app/assets/image_paths.dart';
import '../../../app/responsive/kivo_scale.dart';
import '../../../app/theme/kivo_theme_tokens.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.userName,
    required this.roleLabel,
    required this.energy,
    required this.maxEnergy,
    required this.energyRatio,
    required this.streakDays,
  });

  final String userName;
  final String roleLabel;
  final int energy;
  final int maxEnergy;
  final double energyRatio;
  final int streakDays;

  @override
  Widget build(BuildContext context) {
    final clampedEnergyRatio = energyRatio.clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: KivoScale.w(112),
              height: KivoScale.w(112),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: KivoShadows.soft,
              ),
              padding: EdgeInsets.all(KivoScale.w(10)),
              child: Image.asset(KivoImagePaths.kivoExplorer),
            ),
            SizedBox(width: KivoScale.w(12)),
            SizedBox(
              width: KivoScale.w(158),
              child: Text(
                roleLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: KivoTextStyles.cardTitle.copyWith(
                  fontSize: KivoScale.sp(23, min: 16),
                  color: KivoColors.inkText,
                ),
              ),
            ),
            SizedBox(width: KivoScale.w(12)),
            Expanded(
              child: _EnergyBar(
                energy: energy,
                maxEnergy: maxEnergy,
                ratio: clampedEnergyRatio,
              ),
            ),
            SizedBox(width: KivoScale.w(12)),
            _StreakPill(streakDays: streakDays),
          ],
        ),
        SizedBox(height: KivoScale.h(52)),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text.rich(
                TextSpan(
                  text: 'Chào bạn, ',
                  children: [
                    TextSpan(
                      text: '$userName!',
                      style: KivoTextStyles.screenTitle.copyWith(
                        color: KivoColors.kivoTeal,
                        fontSize: KivoScale.sp(46, min: 28),
                      ),
                    ),
                    const TextSpan(text: ' ❤'),
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: KivoTextStyles.screenTitle.copyWith(
                  fontSize: KivoScale.sp(46, min: 28),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _EnergyBar extends StatelessWidget {
  const _EnergyBar({
    required this.energy,
    required this.maxEnergy,
    required this.ratio,
  });

  final int energy;
  final int maxEnergy;
  final double ratio;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: KivoScale.w(56),
      constraints: BoxConstraints(minWidth: KivoScale.w(180)),
      decoration: BoxDecoration(
        color: KivoColors.softMintCard,
        borderRadius: BorderRadius.circular(KivoScale.r(999)),
        border: Border.all(color: KivoColors.kivoTeal.withAlpha(110), width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          FractionallySizedBox(
            widthFactor: ratio,
            child: Container(
              decoration: const BoxDecoration(
                gradient: KivoGradients.cyanButton,
              ),
            ),
          ),
          Positioned(
            left: KivoScale.w(7),
            child: Image.asset(
              KivoImagePaths.energyDiamond,
              width: KivoScale.w(74),
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.only(right: KivoScale.w(18)),
                child: Text(
                  '$energy/$maxEnergy',
                  style: KivoTextStyles.cardTitle.copyWith(
                    color: KivoColors.deepTeal,
                    fontSize: KivoScale.sp(25, min: 16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakPill extends StatelessWidget {
  const _StreakPill({required this.streakDays});

  final int streakDays;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minWidth: KivoScale.w(118)),
      padding: EdgeInsets.symmetric(
        horizontal: KivoScale.w(16),
        vertical: KivoScale.h(10),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(KivoScale.r(999)),
        border: Border.all(
          color: KivoColors.actionOrange.withAlpha(160),
          width: 1.4,
        ),
        boxShadow: KivoShadows.soft,
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          '🔥 $streakDays',
          textAlign: TextAlign.center,
          style: KivoTextStyles.cardTitle.copyWith(
            color: KivoColors.actionOrange,
            fontSize: KivoScale.sp(26, min: 17),
          ),
        ),
      ),
    );
  }
}
