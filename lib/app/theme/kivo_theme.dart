import 'package:flutter/material.dart';

import 'kivo_colors.dart';
import 'kivo_text_styles.dart';

abstract final class KivoTheme {
  static ThemeData get light {
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: KivoColors.kivoTeal,
        primary: KivoColors.kivoTeal,
        secondary: KivoColors.actionOrange,
        surface: KivoColors.lightSurface,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: KivoColors.lightSurface,
    );

    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        displayLarge: KivoTextStyles.display,
        headlineLarge: KivoTextStyles.screenTitle,
        titleLarge: KivoTextStyles.sectionTitle,
        titleMedium: KivoTextStyles.cardTitle,
        bodyLarge: KivoTextStyles.body,
        bodyMedium: KivoTextStyles.body,
        labelLarge: KivoTextStyles.cta,
        labelMedium: KivoTextStyles.caption,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: KivoColors.inkText,
      ),
    );
  }

  static ThemeData get darkChallenge {
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.dark,
        seedColor: KivoColors.glowMint,
        primary: KivoColors.glowMint,
        secondary: KivoColors.runeGold,
        surface: KivoColors.darkPanel,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: KivoColors.darkCave,
    );

    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        headlineLarge: KivoTextStyles.darkTitle,
        titleLarge: KivoTextStyles.darkTitle,
        bodyLarge: KivoTextStyles.darkBody,
        bodyMedium: KivoTextStyles.darkBody,
        labelLarge: KivoTextStyles.cta.copyWith(color: KivoColors.coffeeText),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: KivoColors.glowMint,
      ),
    );
  }
}
