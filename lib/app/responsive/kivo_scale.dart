import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

abstract final class KivoScale {
  static const Size designSize = Size(852, 1852);

  static double w(num value) => value.w;
  static double h(num value) => value.h;
  static double r(num value) => value.r;

  static double sp(num value, {double min = 10, double? max}) {
    final scaled = value.sp;
    return scaled.clamp(min, max ?? value.toDouble()).toDouble();
  }
}
