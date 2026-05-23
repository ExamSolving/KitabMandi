import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  /// 🧠 BIG HEADINGS (more compact now)
  static TextStyle heading1(BuildContext context) {
    final theme = Theme.of(context);
    return GoogleFonts.poppins(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: theme.textTheme.titleLarge?.color,
      letterSpacing: -0.2,
    );
  }

  static TextStyle heading2(BuildContext context) {
    final theme = Theme.of(context);
    return GoogleFonts.poppins(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: theme.textTheme.titleMedium?.color,
      letterSpacing: -0.1,
    );
  }

  /// 📌 TITLES (cards, lists)
  static TextStyle title(BuildContext context) {
    final theme = Theme.of(context);
    return GoogleFonts.poppins(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: theme.textTheme.bodyLarge?.color,
    );
  }

  /// 📄 BODY TEXT (primary content)
  static TextStyle body(BuildContext context) {
    final theme = Theme.of(context);
    return GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: theme.textTheme.bodyMedium?.color,
      height: 1.3,
    );
  }

  /// 🧩 SECONDARY TEXT
  static TextStyle subtitle(BuildContext context) {
    final theme = Theme.of(context);
    return GoogleFonts.poppins(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: theme.textTheme.bodySmall?.color,
      height: 1.3,
    );
  }

  /// 🧾 SMALL META TEXT (location, time)
  static TextStyle caption(BuildContext context) {
    final theme = Theme.of(context);
    return GoogleFonts.poppins(
      fontSize: 11,
      fontWeight: FontWeight.w400,
      color: theme.hintColor,
    );
  }

  /// 🔘 BUTTON TEXT (keep strong but not oversized)
  static TextStyle button(BuildContext context) {
    return GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Colors.white,
      letterSpacing: 0.2,
    );
  }

  /// 💰 PRICE (marketplace emphasis)
  static TextStyle price(BuildContext context) {
    final theme = Theme.of(context);
    return GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: theme.colorScheme.primary,
    );
  }

  /// 🏷 TAGS / LABELS
  static TextStyle tag(BuildContext context) {
    final theme = Theme.of(context);
    return GoogleFonts.poppins(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: theme.colorScheme.primary,
    );
  }
}
