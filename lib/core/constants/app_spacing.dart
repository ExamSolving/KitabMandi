import 'package:flutter/material.dart';

/// Design-system spacing tokens — use these instead of raw numbers
/// everywhere in the app so spacing is consistent and easy to tweak.
class AppSpacing {
  AppSpacing._();

  // ── Base scale (4-point grid) ──────────────────────────────────────────────
  static const double x2 = 2.0;
  static const double x4 = 4.0;
  static const double x6 = 6.0;
  static const double x8 = 8.0;
  static const double x10 = 10.0;
  static const double x12 = 12.0;
  static const double x14 = 14.0;
  static const double x16 = 16.0;
  static const double x18 = 18.0;
  static const double x20 = 20.0;
  static const double x24 = 24.0;
  static const double x28 = 28.0;
  static const double x32 = 32.0;
  static const double x40 = 40.0;
  static const double x48 = 48.0;
  static const double x56 = 56.0;
  static const double x64 = 64.0;

  // ── Semantic aliases ───────────────────────────────────────────────────────
  static const double micro = x4;
  static const double tiny = x8;
  static const double small = x12;
  static const double medium = x16;
  static const double large = x20;
  static const double xlarge = x24;
  static const double xxlarge = x32;
  static const double section = x40;

  // ── Screen-level padding ───────────────────────────────────────────────────
  static const double screenPaddingH = x16;
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: x16);
  static const EdgeInsets screenPaddingAll = EdgeInsets.all(x16);

  // ── Component-level ────────────────────────────────────────────────────────
  static const double cardPadding = x14;
  static const double listItemPaddingV = x12;
  static const double listItemPaddingH = x16;
  static const double buttonPaddingV = x14;
  static const double inputPaddingH = x16;
  static const double inputPaddingV = x14;
  static const double sectionGap = x14;
  static const double itemGap = x10;

  // ── Icon sizes ─────────────────────────────────────────────────────────────
  static const double iconXs = 14.0;
  static const double iconSm = 16.0;
  static const double iconMd = 20.0;
  static const double iconLg = 24.0;
  static const double iconXl = 32.0;

  // ── Avatar / image sizes ───────────────────────────────────────────────────
  static const double avatarSm = 32.0;
  static const double avatarMd = 40.0;
  static const double avatarLg = 56.0;
  static const double avatarXl = 72.0;

  // ── Button heights ─────────────────────────────────────────────────────────
  static const double buttonHeightSm = 40.0;
  static const double buttonHeightMd = 48.0;
  static const double buttonHeightLg = 54.0;

  // ── AppBar ─────────────────────────────────────────────────────────────────
  static const double appBarHeight = 56.0;
  static const double appBarElevation = 0.0;
  static const double bottomNavHeight = 64.0;
}

/// Border-radius tokens
class AppRadius {
  AppRadius._();

  static const double sm = 6.0;
  static const double md = 10.0;
  static const double lg = 14.0;
  static const double xl = 18.0;
  static const double xxl = 24.0;

  // ── Component-specific ────────────────────────────────────────────────────
  static const double card = 16.0;
  static const double button = 14.0;
  static const double input = 12.0;
  static const double chip = 20.0;
  static const double dialog = 20.0;
  static const double bottomSheet = 24.0;
  static const double image = 12.0;
  static const double tag = 6.0;
  static const double badge = 100.0;
  static const double full = 100.0;

  // ── Pre-built border radii ────────────────────────────────────────────────
  static final BorderRadius cardBR = BorderRadius.circular(card);
  static final BorderRadius buttonBR = BorderRadius.circular(button);
  static final BorderRadius inputBR = BorderRadius.circular(input);
  static final BorderRadius chipBR = BorderRadius.circular(chip);
  static final BorderRadius dialogBR = BorderRadius.circular(dialog);
  static final BorderRadius bottomSheetBR = BorderRadius.only(
    topLeft: Radius.circular(bottomSheet),
    topRight: Radius.circular(bottomSheet),
  );
  static final BorderRadius imageBR = BorderRadius.circular(image);
  static final BorderRadius fullBR = BorderRadius.circular(full);
}

/// Elevation / shadow tokens
class AppElevation {
  AppElevation._();

  static const double none = 0;
  static const double xs = 1;
  static const double sm = 2;
  static const double md = 4;
  static const double lg = 8;
  static const double xl = 16;

  static List<BoxShadow> card(bool isDark) => [
        BoxShadow(
          color: isDark
              ? const Color(0x40000000)
              : const Color(0x0D000000),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> button(Color primary) => [
        BoxShadow(
          color: primary.withValues(alpha: 0.30),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> bottomNav(bool isDark) => [
        BoxShadow(
          color: isDark
              ? const Color(0x66000000)
              : const Color(0x14000000),
          blurRadius: 20,
          offset: const Offset(0, -4),
        ),
      ];
}
