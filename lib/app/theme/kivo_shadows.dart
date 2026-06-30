import 'package:flutter/material.dart';

import 'kivo_colors.dart';

abstract final class KivoShadows {
  static const List<BoxShadow> soft = [
    BoxShadow(color: KivoColors.shadow, blurRadius: 18, offset: Offset(0, 8)),
  ];

  static const List<BoxShadow> raised = [
    BoxShadow(color: KivoColors.shadow, blurRadius: 24, offset: Offset(0, 12)),
  ];

  static const List<BoxShadow> tealGlow = [
    BoxShadow(color: KivoColors.tealShadow, blurRadius: 24, spreadRadius: 1),
  ];

  static const List<BoxShadow> orangeGlow = [
    BoxShadow(
      color: KivoColors.orangeShadow,
      blurRadius: 22,
      offset: Offset(0, 8),
    ),
  ];
}
