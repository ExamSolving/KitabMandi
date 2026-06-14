import 'package:flutter/material.dart';

/// Single source of truth for all color tokens.
/// Consume via [AppColors.primary], [AppColors.darkBackground], etc.
/// Never hardcode hex literals inside widgets — reference these tokens.
class AppColors {
  AppColors._();

  // ── Brand ─────────────────────────────────────────────────────────────────

  /// Primary green — main brand identity
  static const Color primary = Color(0xFF1B5E20);
  static const Color primaryLight = Color(0xFF43A047);
  static const Color primaryDark = Color(0xFF0D3B12);
  static const Color primaryContainer = Color(0xFFC8E6C9);
  static const Color onPrimaryContainer = Color(0xFF002205);

  /// Secondary orange — CTA / energy
  static const Color secondary = Color(0xFFFF7A00);
  static const Color secondaryLight = Color(0xFFFFA040);
  static const Color secondaryDark = Color(0xFFE65100);
  static const Color secondaryContainer = Color(0xFFFFE0CC);
  static const Color onSecondaryContainer = Color(0xFF4A1700);

  // ── Light-theme semantic tokens ────────────────────────────────────────────

  static const Color background = Color(0xFFF7F8FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF2F3F5);
  static const Color surfaceElevated = Color(0xFFF9FAFB);

  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textDisabled = Color(0xFFD1D5DB);

  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFF3F4F6);

  // ── Dark-theme tokens ──────────────────────────────────────────────────────

  static const Color darkPrimary = Color(0xFF66BB6A);
  static const Color darkPrimaryLight = Color(0xFF81C784);
  static const Color darkPrimaryDark = Color(0xFF2E7D32);
  static const Color darkPrimaryContainer = Color(0xFF1B5E20);
  static const Color darkOnPrimaryContainer = Color(0xFFC8E6C9);

  static const Color darkSecondary = Color(0xFFFFA040);
  static const Color darkSecondaryDark = Color(0xFFFF7A00);
  static const Color darkSecondaryContainer = Color(0xFF6B2400);
  static const Color darkOnSecondaryContainer = Color(0xFFFFDBCC);

  static const Color darkBackground = Color(0xFF0F1115);
  static const Color darkSurface = Color(0xFF1A1D23);
  static const Color darkSurfaceVariant = Color(0xFF22252B);
  static const Color darkSurfaceElevated = Color(0xFF25282F);

  static const Color darkTextPrimary = Color(0xFFEAEBED);
  static const Color darkTextSecondary = Color(0xFFB0B3B8);
  static const Color darkTextTertiary = Color(0xFF6B7280);
  static const Color darkTextDisabled = Color(0xFF3A3D44);

  static const Color darkBorder = Color(0xFF2C2F36);
  static const Color darkDivider = Color(0xFF1E2128);

  // ── Status colors ──────────────────────────────────────────────────────────

  static const Color success = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color error = Color(0xFFD32F2F);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFFFBEB);
  static const Color info = Color(0xFF1565C0);
  static const Color infoLight = Color(0xFFE3F2FD);

  // ── Utility ───────────────────────────────────────────────────────────────

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Colors.transparent;

  /// Soft modal overlay
  static const Color overlay = Color(0x80000000);

  /// Subtle card shadow (light mode)
  static const Color shadowLight = Color(0x0D000000);

  /// Stronger card shadow (dark mode)
  static const Color shadowDark = Color(0x40000000);

  // ── Gradients ─────────────────────────────────────────────────────────────

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
  );

  static const LinearGradient darkPrimaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
  );

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1B5E20), Color(0xFF0D3B12)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FAF8)],
  );
}
