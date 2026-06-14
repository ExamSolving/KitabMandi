import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kitab_mandi/core/utils/responsive.dart';

/// Typographic scale for KitabMandi.
///
/// All sizes pass through [Responsive.sp] so they scale proportionally
/// on small phones (< 360 dp) and large phones (> 414 dp) while
/// remaining stable on typical devices.
///
/// Usage:
/// ```dart
/// Text('Hello', style: AppTextStyles.heading1(context))
/// ```
class AppTextStyles {
  AppTextStyles._();

  // ── Display ───────────────────────────────────────────────────────────────
  /// Hero text — splash / large empty states
  static TextStyle display(BuildContext context) => GoogleFonts.poppins(
        fontSize: Responsive.sp(context, 32),
        fontWeight: FontWeight.w800,
        color: Theme.of(context).textTheme.displayLarge?.color,
        letterSpacing: -1.0,
        height: 1.15,
      );

  // ── Headings ──────────────────────────────────────────────────────────────

  /// Page / screen title (22–24 sp)
  static TextStyle heading1(BuildContext context) => GoogleFonts.poppins(
        fontSize: Responsive.sp(context, 22),
        fontWeight: FontWeight.w700,
        color: Theme.of(context).textTheme.titleLarge?.color,
        letterSpacing: -0.4,
        height: 1.2,
      );

  /// Section headers / AppBar titles (18–20 sp)
  static TextStyle heading2(BuildContext context) => GoogleFonts.poppins(
        fontSize: Responsive.sp(context, 18),
        fontWeight: FontWeight.w600,
        color: Theme.of(context).textTheme.titleMedium?.color,
        letterSpacing: -0.2,
        height: 1.25,
      );

  /// Card section labels (16 sp)
  static TextStyle heading3(BuildContext context) => GoogleFonts.poppins(
        fontSize: Responsive.sp(context, 16),
        fontWeight: FontWeight.w600,
        color: Theme.of(context).textTheme.titleSmall?.color,
        letterSpacing: -0.1,
        height: 1.3,
      );

  // ── Body copy ─────────────────────────────────────────────────────────────

  /// Primary content — list titles, card headers (15 sp semi-bold)
  static TextStyle title(BuildContext context) => GoogleFonts.poppins(
        fontSize: Responsive.sp(context, 15),
        fontWeight: FontWeight.w600,
        color: Theme.of(context).textTheme.bodyLarge?.color,
        height: 1.4,
        letterSpacing: 0.1,
      );

  /// Standard body text (14 sp)
  static TextStyle body(BuildContext context) => GoogleFonts.poppins(
        fontSize: Responsive.sp(context, 14),
        fontWeight: FontWeight.w400,
        color: Theme.of(context).textTheme.bodyMedium?.color,
        height: 1.55,
      );

  /// Medium-weight body — slightly more prominent than body (14 sp w500)
  static TextStyle bodyMedium(BuildContext context) => GoogleFonts.poppins(
        fontSize: Responsive.sp(context, 14),
        fontWeight: FontWeight.w500,
        color: Theme.of(context).textTheme.bodyMedium?.color,
        height: 1.5,
      );

  /// Secondary text — captions, metadata labels (13 sp)
  static TextStyle subtitle(BuildContext context) => GoogleFonts.poppins(
        fontSize: Responsive.sp(context, 13),
        fontWeight: FontWeight.w400,
        color: Theme.of(context).textTheme.bodySmall?.color,
        height: 1.5,
      );

  // ── Micro text ────────────────────────────────────────────────────────────

  /// Tiny meta — timestamps, location hints (11 sp)
  static TextStyle caption(BuildContext context) => GoogleFonts.poppins(
        fontSize: Responsive.sp(context, 11),
        fontWeight: FontWeight.w400,
        color: Theme.of(context).hintColor,
        height: 1.4,
        letterSpacing: 0.1,
      );

  /// All-caps micro label — badges, status pills (10 sp w600)
  static TextStyle overline(BuildContext context) => GoogleFonts.poppins(
        fontSize: Responsive.sp(context, 10),
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.primary,
        letterSpacing: 0.8,
        height: 1.4,
      );

  /// Form field labels (12 sp w500)
  static TextStyle label(BuildContext context) => GoogleFonts.poppins(
        fontSize: Responsive.sp(context, 12),
        fontWeight: FontWeight.w500,
        color: Theme.of(context).textTheme.labelLarge?.color,
        height: 1.4,
        letterSpacing: 0.1,
      );

  // ── Interactive ───────────────────────────────────────────────────────────

  /// Button / CTA label (15 sp w600)
  static TextStyle button(BuildContext context) => GoogleFonts.poppins(
        fontSize: Responsive.sp(context, 15),
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 0.3,
        height: 1.2,
      );

  /// Inline hyperlinks (14 sp w500 underlined)
  static TextStyle link(BuildContext context) => GoogleFonts.poppins(
        fontSize: Responsive.sp(context, 14),
        fontWeight: FontWeight.w500,
        color: Theme.of(context).colorScheme.primary,
        decoration: TextDecoration.underline,
        decorationColor: Theme.of(context).colorScheme.primary,
      );

  // ── Marketplace-specific ─────────────────────────────────────────────────

  /// Product price — large and bold (20 sp)
  static TextStyle price(BuildContext context) => GoogleFonts.poppins(
        fontSize: Responsive.sp(context, 20),
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.primary,
        letterSpacing: -0.3,
        height: 1.2,
      );

  /// Compact price — cards (16 sp)
  static TextStyle priceSmall(BuildContext context) => GoogleFonts.poppins(
        fontSize: Responsive.sp(context, 16),
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.primary,
        letterSpacing: -0.2,
      );

  /// Chip / tag label (11 sp w500)
  static TextStyle tag(BuildContext context) => GoogleFonts.poppins(
        fontSize: Responsive.sp(context, 11),
        fontWeight: FontWeight.w500,
        color: Theme.of(context).colorScheme.primary,
        letterSpacing: 0.2,
      );
}
