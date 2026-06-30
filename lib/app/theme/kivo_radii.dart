import 'package:flutter/material.dart';

abstract final class KivoRadii {
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 22;
  static const double xl = 28;
  static const double xxl = 36;
  static const double pill = 999;

  static BorderRadius get card => BorderRadius.circular(lg);
  static BorderRadius get largeCard => BorderRadius.circular(xl);
  static BorderRadius get button => BorderRadius.circular(24);
  static BorderRadius get chip => BorderRadius.circular(pill);
  static BorderRadius get bottomSheetTop =>
      const BorderRadius.vertical(top: Radius.circular(30));
}
