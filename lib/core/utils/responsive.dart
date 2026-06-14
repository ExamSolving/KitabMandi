import 'package:flutter/material.dart';

/// Responsive utility.
/// Design baseline: iPhone 14 Pro — 390 × 844 logical pixels.
/// All scale functions are clamped to prevent extreme values on very
/// small (< 320 dp) or very large (> 500 dp) screens.
class Responsive {
  Responsive._();

  static const double _baseW = 390.0;
  static const double _baseH = 844.0;

  // ── Raw screen dimensions ──────────────────────────────────────────────────

  static double screenWidth(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.sizeOf(context).height;

  // ── Proportional scaling ───────────────────────────────────────────────────

  /// Scale a width-related value proportionally.
  static double w(BuildContext context, double size) =>
      size * (screenWidth(context) / _baseW);

  /// Scale a height-related value proportionally.
  static double h(BuildContext context, double size) =>
      size * (screenHeight(context) / _baseH);

  /// Scale a font size — clamped ±15 % of baseline.
  static double sp(BuildContext context, double size) {
    final scale =
        (screenWidth(context) / _baseW).clamp(0.85, 1.15);
    return (size * scale).roundToDouble();
  }

  /// Width as a percentage of screen width (0–100).
  static double wp(BuildContext context, double pct) =>
      screenWidth(context) * (pct / 100);

  /// Height as a percentage of screen height (0–100).
  static double hp(BuildContext context, double pct) =>
      screenHeight(context) * (pct / 100);

  // ── Breakpoints ────────────────────────────────────────────────────────────

  static bool isSmall(BuildContext context) =>
      screenWidth(context) < 360;

  static bool isNormal(BuildContext context) {
    final w = screenWidth(context);
    return w >= 360 && w < 414;
  }

  static bool isLarge(BuildContext context) =>
      screenWidth(context) >= 414;

  // ── Adaptive values ────────────────────────────────────────────────────────

  /// Horizontal screen padding that adapts to device width.
  static double horizontalPadding(BuildContext context) {
    if (isSmall(context)) return 14.0;
    if (isLarge(context)) return 20.0;
    return 16.0;
  }

  static EdgeInsets horizontalInsets(BuildContext context) =>
      EdgeInsets.symmetric(horizontal: horizontalPadding(context));

  /// Standard button height clamped for ergonomics.
  static double buttonHeight(BuildContext context) =>
      h(context, 52).clamp(46, 58);

  /// Adaptive card corner radius.
  static double cardRadius(BuildContext context) =>
      isSmall(context) ? 12.0 : 16.0;
}
