import 'package:flutter/material.dart';

import 'kivo_colors.dart';

abstract final class KivoGradients {
  static const LinearGradient lightBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFFCF7), KivoColors.cream],
  );

  static const LinearGradient mintCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE9FFF8), Color(0xFFD8FFF5)],
  );

  static const LinearGradient cyanButton = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF18D6C6), KivoColors.actionCyan],
  );

  static const LinearGradient orangeButton = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFF9B2F), KivoColors.actionOrange],
  );

  static const LinearGradient darkChallengeBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [KivoColors.darkCave, Color(0xFF003034)],
  );

  static const LinearGradient darkPanel = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xCC063C40), Color(0x99001E24)],
  );
}
