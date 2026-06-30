import 'package:flutter/material.dart';

import '../icons/kivo_icon_registry.dart';
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
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: KivoColors.lightBorder, width: 0.8),
          ),
          boxShadow: KivoShadows.soft,
        ),
        padding: const EdgeInsets.fromLTRB(
          KivoSpacing.md,
          KivoSpacing.xs,
          KivoSpacing.md,
          KivoSpacing.xs,
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
    final color = isSelected ? KivoColors.actionCyan : KivoColors.disabledText;
    final tone = isSelected ? KivoIconTone.duotone : KivoIconTone.regular;

    return Semantics(
      button: true,
      selected: isSelected,
      label: item.semanticLabel,
      child: InkWell(
        onTap: onTap,
        borderRadius: KivoRadii.chip,
        child: SizedBox(
          height: 68,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              AnimatedPositioned(
                duration: KivoDurations.fast,
                curve: Curves.easeOutCubic,
                top: isSelected ? 2 : 10,
                child: AnimatedContainer(
                  duration: KivoDurations.fast,
                  curve: Curves.easeOutCubic,
                  width: isSelected ? 48 : 42,
                  height: isSelected ? 48 : 42,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? KivoColors.softMintCard
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? KivoColors.actionCyan
                          : KivoColors.disabledText,
                      width: isSelected ? 3 : 2.4,
                    ),
                    boxShadow: isSelected ? KivoShadows.tealGlow : null,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    KivoIconRegistry.system(item.iconKey, tone: tone),
                    size: isSelected ? 28 : 27,
                    color: color,
                  ),
                ),
              ),
              AnimatedDefaultTextStyle(
                duration: KivoDurations.fast,
                curve: Curves.easeOutCubic,
                style: KivoTextStyles.caption.copyWith(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
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
