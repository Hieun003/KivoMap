import 'package:flutter/material.dart';

import '../../../app/assets/image_paths.dart';
import '../../../app/icons/kivo_icon_registry.dart';
import '../../../app/responsive/kivo_scale.dart';
import '../../../app/theme/kivo_theme_tokens.dart';
import '../view_model/home_view_state.dart';

class HomeCategoryFilterBar extends StatelessWidget {
  const HomeCategoryFilterBar({
    super.key,
    required this.categories,
    required this.onSelected,
  });

  final List<HomeCategoryChipData> categories;
  final ValueChanged<HomeCategoryChipData> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: KivoScale.w(70),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) => SizedBox(width: KivoScale.w(12)),
        itemBuilder: (context, index) {
          final category = categories[index];
          return _CategoryChip(category: category, onSelected: onSelected);
        },
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.category, required this.onSelected});

  final HomeCategoryChipData category;
  final ValueChanged<HomeCategoryChipData> onSelected;

  @override
  Widget build(BuildContext context) {
    final foreground = category.isSelected
        ? KivoColors.deepTeal
        : KivoColors.inkText;
    final background = category.isSelected
        ? KivoColors.softMintCard
        : Colors.white.withAlpha(235);
    final borderColor = category.isSelected
        ? KivoColors.kivoTeal.withAlpha(118)
        : KivoColors.lightBorder.withAlpha(170);

    return Semantics(
      button: true,
      selected: category.isSelected,
      child: InkWell(
        key: ValueKey('home-category-${category.iconKey}'),
        onTap: () => onSelected(category),
        borderRadius: BorderRadius.circular(KivoScale.r(999)),
        child: AnimatedContainer(
          duration: KivoDurations.fast,
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(horizontal: KivoScale.w(18)),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(KivoScale.r(999)),
            border: Border.all(
              color: borderColor,
              width: category.isSelected ? 1.4 : 0.9,
            ),
            boxShadow: category.isSelected
                ? [
                    BoxShadow(
                      color: KivoColors.tealShadow.withAlpha(18),
                      blurRadius: KivoScale.r(8),
                      offset: Offset(0, KivoScale.h(2)),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _CategoryIcon(
                iconKey: category.iconKey,
                color: category.isSelected
                    ? KivoColors.kivoTeal
                    : KivoColors.actionCyan,
              ),
              SizedBox(width: KivoScale.w(8)),
              Text(
                category.label,
                style: KivoTextStyles.caption.copyWith(
                  color: foreground,
                  fontSize: KivoScale.sp(16.5, min: 12.5),
                  fontWeight: category.isSelected
                      ? FontWeight.w800
                      : FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  const _CategoryIcon({required this.iconKey, required this.color});

  final String iconKey;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (_isSecretPath(iconKey)) {
      return Image.asset(
        KivoImagePaths.mysteryStoneGate,
        width: KivoScale.w(31),
        height: KivoScale.w(31),
        fit: BoxFit.contain,
      );
    }

    return Icon(
      iconKey == 'default'
          ? KivoIconRegistry.system('default', tone: KivoIconTone.fill)
          : KivoIconRegistry.topic(iconKey, tone: KivoIconTone.fill),
      size: KivoScale.w(29),
      color: color,
    );
  }
}

bool _isSecretPath(String iconKey) {
  final normalizedKey = iconKey.trim().toLowerCase().replaceAll(
    RegExp(r'[\s-]+'),
    '_',
  );
  return normalizedKey == 'secret_path' || normalizedKey == 'secret_passage';
}
