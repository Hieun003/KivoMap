import 'package:flutter/material.dart';

import 'kivo_colors.dart';

abstract final class KivoTextStyles {
  static const String fontFamily = 'KivoRounded';

  static const TextStyle display = TextStyle(
    fontSize: 42,
    height: 1.12,
    fontWeight: FontWeight.w800,
    color: KivoColors.coffeeText,
  );

  static const TextStyle screenTitle = TextStyle(
    fontSize: 32,
    height: 1.18,
    fontWeight: FontWeight.w800,
    color: KivoColors.coffeeText,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 24,
    height: 1.22,
    fontWeight: FontWeight.w800,
    color: KivoColors.inkText,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 20,
    height: 1.25,
    fontWeight: FontWeight.w800,
    color: KivoColors.inkText,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    height: 1.45,
    fontWeight: FontWeight.w500,
    color: KivoColors.inkText,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 13,
    height: 1.35,
    fontWeight: FontWeight.w600,
    color: KivoColors.secondaryText,
  );

  static const TextStyle cta = TextStyle(
    fontSize: 26,
    height: 1.15,
    fontWeight: FontWeight.w800,
    color: Colors.white,
  );

  static const TextStyle darkTitle = TextStyle(
    fontSize: 30,
    height: 1.18,
    fontWeight: FontWeight.w800,
    color: KivoColors.darkText,
  );

  static const TextStyle darkBody = TextStyle(
    fontSize: 18,
    height: 1.42,
    fontWeight: FontWeight.w700,
    color: KivoColors.darkText,
  );

  static const TextStyle darkAccent = TextStyle(
    fontSize: 18,
    height: 1.3,
    fontWeight: FontWeight.w800,
    color: KivoColors.glowMint,
  );
}
