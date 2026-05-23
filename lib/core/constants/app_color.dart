import 'package:flutter/material.dart';

class AppColors {
  // =========================
  // 🌿 LIGHT THEME (PRIMARY BRAND)
  // =========================

  // Main Brand Colors
  static const Color primary = Color(0xFF1B5E20); // Deep Green (main brand)
  static const Color primaryLight = Color(
    0xFF43A047,
  ); // Fresh Green (hover/highlight)
  static const Color primaryDark = Color(
    0xFF0D3B12,
  ); // Dark Green (premium depth)

  static const Color secondary = Color(0xFFFF7A00); // Orange (CTA / actions)
  static const Color secondaryLight = Color(0xFFFFA040);
  static const Color secondaryDark = Color(0xFFE65100);

  // Backgrounds
  static const Color background = Color(
    0xFFF8FAF8,
  ); // Slight green tint (premium)
  static const Color card = Color(0xFFFFFFFF); // Clean white cards
  static const Color surface = Color(0xFFE8F5E9); // Soft green surface

  // Text Colors
  static const Color textPrimary = Color(0xFF1C1C1C);
  static const Color textSecondary = Color(0xFF6B7280); // modern grey
  static const Color textLight = Color(0xFF9E9E9E);

  // Borders & Divider
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFEEEEEE);

  // Status Colors
  static const Color success = Color(0xFF2E7D32);
  static const Color error = Color(0xFFD32F2F);
  static const Color warning = Color(0xFFF9A825);

  // =========================
  // 🌙 DARK THEME
  // =========================

  static const Color darkPrimary = Color(0xFF66BB6A);
  static const Color darkPrimaryDark = Color(0xFF2E7D32);

  static const Color darkSecondary = Color(0xFFFFA040);

  static const Color darkBackground = Color(0xFF0F1115);
  static const Color darkCard = Color(0xFF1A1D22);
  static const Color darkSurface = Color(0xFF22252B);

  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB0B3B8);
  static const Color darkTextLight = Color(0xFF80868B);

  static const Color darkBorder = Color(0xFF2C2F36);
  static const Color darkDivider = Color(0xFF2A2D33);

  // =========================
  // 🎯 EXTRA UI COLORS (VERY USEFUL)
  // =========================

  static const Color price = secondary; // price highlight (orange)
  static const Color iconPrimary = primary;
  static const Color iconSecondary = secondary;

  static const Color shadow = Color(0x14000000); // soft shadow
  static const Color overlay = Color(0x66000000); // modal overlay

  // Common
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
}
