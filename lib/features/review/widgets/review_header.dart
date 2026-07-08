import 'package:flutter/material.dart';

import '../../../app/assets/image_paths.dart';
import '../../../app/icons/kivo_icon_registry.dart';
import '../../../app/responsive/kivo_scale.dart';
import '../../../app/theme/kivo_theme_tokens.dart';
import '../view_model/review_view_state.dart';

class ReviewHeader extends StatelessWidget {
  const ReviewHeader({
    required this.state,
    required this.progress,
    required this.onBack,
    super.key,
  });

  final ReviewSessionState state;
  final double progress;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final energyRatio = state.maxEnergy == 0
        ? 0.0
        : state.energy / state.maxEnergy;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(236),
        boxShadow: [
          BoxShadow(
            color: KivoColors.shadow.withAlpha(18),
            blurRadius: 20,
            offset: Offset(0, KivoScale.h(8)),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              KivoScale.w(24),
              KivoScale.h(20),
              KivoScale.w(24),
              KivoScale.h(26),
            ),
            child: Row(
              children: [
                _HeaderIconButton(onPressed: onBack),
                SizedBox(width: KivoScale.w(12)),
                const _ExplorerAvatar(),
                SizedBox(width: KivoScale.w(14)),
                _RoleLabel(label: state.roleLabel),
                SizedBox(width: KivoScale.w(18)),
                Expanded(
                  child: _EnergyMeter(
                    energy: state.energy,
                    maxEnergy: state.maxEnergy,
                    ratio: energyRatio.clamp(0.0, 1.0),
                  ),
                ),
                SizedBox(width: KivoScale.w(18)),
                _StreakPill(streakDays: state.streakDays),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(KivoScale.r(999)),
            child: LinearProgressIndicator(
              minHeight: KivoScale.h(9),
              value: progress.clamp(0.0, 1.0),
              backgroundColor: KivoColors.lightBorder.withAlpha(160),
              color: KivoColors.kivoTeal,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      tooltip: 'Quay lại',
      onPressed: onPressed,
      icon: Icon(
        KivoIconRegistry.system('back', tone: KivoIconTone.bold),
        size: KivoScale.w(26),
      ),
    );
  }
}

class _ExplorerAvatar extends StatelessWidget {
  const _ExplorerAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: KivoScale.w(90),
      height: KivoScale.w(90),
      padding: EdgeInsets.all(KivoScale.w(8)),
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: KivoShadows.soft,
      ),
      child: Image.asset(KivoImagePaths.kivoExplorer),
    );
  }
}

class _RoleLabel extends StatelessWidget {
  const _RoleLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: KivoTextStyles.cardTitle.copyWith(
        color: KivoColors.inkText,
        fontSize: KivoScale.sp(24, min: 16),
      ),
    );
  }
}

class _EnergyMeter extends StatelessWidget {
  const _EnergyMeter({
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
      height: KivoScale.h(62),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(KivoScale.r(999)),
        border: Border.all(color: KivoColors.lightBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.center,
        children: [
          FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: ratio,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: KivoGradients.cyanButton,
                borderRadius: BorderRadius.circular(KivoScale.r(999)),
              ),
            ),
          ),
          Text(
            '$energy/$maxEnergy',
            style: KivoTextStyles.cardTitle.copyWith(
              color: KivoColors.inkText,
              fontSize: KivoScale.sp(23, min: 15),
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
      constraints: BoxConstraints(minWidth: KivoScale.w(104)),
      padding: EdgeInsets.symmetric(
        horizontal: KivoScale.w(16),
        vertical: KivoScale.h(10),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(KivoScale.r(999)),
        border: Border.all(color: KivoColors.actionOrange.withAlpha(150)),
        boxShadow: KivoShadows.soft,
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              KivoIconRegistry.reward('streak', tone: KivoIconTone.fill),
              color: KivoColors.actionOrange,
              size: KivoScale.w(24),
            ),
            SizedBox(width: KivoScale.w(6)),
            Text(
              '$streakDays',
              style: KivoTextStyles.cardTitle.copyWith(
                color: KivoColors.actionOrange,
                fontSize: KivoScale.sp(24, min: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
