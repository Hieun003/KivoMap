import 'package:flutter/material.dart';

import '../icons/kivo_icon_registry.dart';
import '../responsive/kivo_scale.dart';
import '../theme/kivo_theme_tokens.dart';

class KivoBottomNavItem {
  const KivoBottomNavItem({
    required this.label,
    required this.iconKey,
    required this.semanticLabel,
  });

  final String label;
  final String iconKey;
  final String semanticLabel;
}

class KivoBottomNav extends StatelessWidget {
  const KivoBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onSelected,
  });

  final List<KivoBottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: KivoColors.lightBorder, width: 0.8),
          ),
          boxShadow: [
            BoxShadow(
              color: KivoColors.shadow.withAlpha(18),
              blurRadius: KivoScale.r(16),
              offset: Offset(0, KivoScale.h(-4)),
            ),
          ],
        ),
        padding: EdgeInsets.fromLTRB(
          KivoScale.w(20),
          KivoScale.h(20),
          KivoScale.w(20),
          KivoScale.h(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var index = 0; index < items.length; index += 1)
              Expanded(
                child: _KivoBottomNavButton(
                  item: items[index],
                  isSelected: index == currentIndex,
                  onTap: () => onSelected(index),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _KivoBottomNavButton extends StatelessWidget {
  const _KivoBottomNavButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final KivoBottomNavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color =
    isSelected ? KivoColors.actionCyan : KivoColors.disabledText;

    final tone =
    isSelected ? KivoIconTone.duotone : KivoIconTone.regular;

    final circleSize = isSelected
        ? KivoScale.w(100)
        : KivoScale.w(100);

    final iconSize = isSelected
        ? KivoScale.w(50)
        : KivoScale.w(50);

    return Semantics(
      button: true,
      selected: isSelected,
      label: item.semanticLabel,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: KivoScale.h(6),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              AnimatedContainer(
                duration: KivoDurations.fast,
                curve: Curves.easeOutCubic,
                width: circleSize,
                height: circleSize,
                decoration: BoxDecoration(
                  color: isSelected
                      ? KivoColors.softMintCard
                      : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color,
                    width: isSelected ? 2.2 : 1.8,
                  ),
                  boxShadow: isSelected
                      ? [
                    BoxShadow(
                      color:
                      KivoColors.tealShadow.withAlpha(35),
                      blurRadius: KivoScale.r(14),
                    ),
                  ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Icon(
                  KivoIconRegistry.system(
                    item.iconKey,
                    tone: tone,
                  ),
                  color: color,
                  size: iconSize,
                ),
              ),

              SizedBox(height: KivoScale.h(6)),

              AnimatedDefaultTextStyle(
                duration: KivoDurations.fast,
                curve: Curves.easeOutCubic,
                style: KivoTextStyles.caption.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: KivoScale.sp(12.5, min: 11),
                ),
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
