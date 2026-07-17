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
    this.compact = false,
  });

  final List<KivoBottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onSelected;
  final bool compact;

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
          compact ? KivoScale.h(12) : KivoScale.h(20),
          KivoScale.w(20),
          compact ? KivoScale.h(12) : KivoScale.h(20),
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
                  compact: compact,
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
    required this.compact,
  });

  final KivoBottomNavItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? KivoColors.actionCyan : KivoColors.disabledText;

    final tone = isSelected ? KivoIconTone.duotone : KivoIconTone.regular;

    final circleSize = compact ? KivoScale.w(74) : KivoScale.w(100);

    final iconSize = compact ? KivoScale.w(34) : KivoScale.w(50);

    return Semantics(
      button: true,
      selected: isSelected,
      label: item.semanticLabel,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: compact ? KivoScale.h(3) : KivoScale.h(6),
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
                    width: compact
                        ? (isSelected ? 1.8 : 1.3)
                        : (isSelected ? 2.2 : 1.8),
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: KivoColors.tealShadow.withAlpha(35),
                            blurRadius: KivoScale.r(14),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Icon(
                  KivoIconRegistry.system(item.iconKey, tone: tone),
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
                  fontSize: compact
                      ? KivoScale.sp(11.5, min: 10)
                      : KivoScale.sp(12.5, min: 11),
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
