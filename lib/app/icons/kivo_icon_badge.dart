import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../theme/kivo_colors.dart';
import '../theme/kivo_radii.dart';
import '../theme/kivo_shadows.dart';

class KivoIconBadge extends StatelessWidget {
  const KivoIconBadge({
    super.key,
    required this.icon,
    this.size = 56,
    this.iconSize,
    this.foregroundColor = KivoColors.kivoTeal,
    this.backgroundColor = KivoColors.softMintCard,
    this.borderColor,
    this.shadows = KivoShadows.soft,
    this.semanticLabel,
  });

  final IconData icon;
  final double size;
  final double? iconSize;
  final Color foregroundColor;
  final Color backgroundColor;
  final Color? borderColor;
  final List<BoxShadow> shadows;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(KivoRadii.lg),
        border: Border.all(color: borderColor ?? foregroundColor.withAlpha(77)),
        boxShadow: shadows,
      ),
      alignment: Alignment.center,
      child: PhosphorIcon(
        icon,
        color: foregroundColor,
        size: iconSize ?? size * 0.54,
        semanticLabel: semanticLabel,
      ),
    );
  }
}
