import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kitab_mandi/core/constants/app_color.dart';
import 'package:kitab_mandi/core/constants/app_spacing.dart';

/// Full Material 3 theme for KitabMandi.
///
/// Explicit [ColorScheme] values are used (instead of fromSeed) so every
/// generated tonal surface matches the brand exactly.
class AppTheme {
  AppTheme._();

  // ════════════════════════════════════════════════════════════════════════════
  //  LIGHT THEME
  // ════════════════════════════════════════════════════════════════════════════

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,

        // ── Color scheme ────────────────────────────────────────────────────
        colorScheme: _lightColorScheme,

        // ── Scaffold ────────────────────────────────────────────────────────
        scaffoldBackgroundColor: AppColors.background,

        // ── Typography ──────────────────────────────────────────────────────
        textTheme: _textTheme(Brightness.light),
        fontFamily: GoogleFonts.poppins().fontFamily,

        // ── System UI overlay ───────────────────────────────────────────────
        appBarTheme: _lightAppBar,
        cardTheme: _lightCard,
        inputDecorationTheme: _lightInput,
        elevatedButtonTheme: _lightElevatedButton,
        outlinedButtonTheme: _outlinedButton,
        textButtonTheme: _textButton,
        chipTheme: _lightChip,
        switchTheme: _lightSwitch,
        checkboxTheme: _lightCheckbox,
        tabBarTheme: _lightTabBar,
        bottomNavigationBarTheme: _lightBottomNav,
        navigationBarTheme: _navigationBar,
        listTileTheme: _lightListTile,
        dividerTheme: _lightDivider,
        snackBarTheme: _lightSnackBar,
        dialogTheme: _lightDialog,
        bottomSheetTheme: _bottomSheet,
        floatingActionButtonTheme: _lightFab,
        progressIndicatorTheme: _progressIndicator(AppColors.primary),
        iconTheme: const IconThemeData(color: Color(0xFF2E2E2E), size: AppSpacing.iconLg),
        iconButtonTheme: _iconButton,
        popupMenuTheme: _lightPopupMenu,
      );

  // ════════════════════════════════════════════════════════════════════════════
  //  DARK THEME
  // ════════════════════════════════════════════════════════════════════════════

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,

        colorScheme: _darkColorScheme,

        scaffoldBackgroundColor: AppColors.darkBackground,

        textTheme: _textTheme(Brightness.dark),
        fontFamily: GoogleFonts.poppins().fontFamily,

        appBarTheme: _darkAppBar,
        cardTheme: _darkCard,
        inputDecorationTheme: _darkInput,
        elevatedButtonTheme: _darkElevatedButton,
        outlinedButtonTheme: _outlinedButton,
        textButtonTheme: _textButton,
        chipTheme: _darkChip,
        switchTheme: _darkSwitch,
        checkboxTheme: _darkCheckbox,
        tabBarTheme: _darkTabBar,
        bottomNavigationBarTheme: _darkBottomNav,
        navigationBarTheme: _navigationBar,
        listTileTheme: _darkListTile,
        dividerTheme: _darkDivider,
        snackBarTheme: _darkSnackBar,
        dialogTheme: _darkDialog,
        bottomSheetTheme: _bottomSheet,
        floatingActionButtonTheme: _darkFab,
        progressIndicatorTheme: _progressIndicator(AppColors.darkPrimary),
        iconTheme: const IconThemeData(color: Color(0xFFD1D5DB), size: AppSpacing.iconLg),
        iconButtonTheme: _iconButton,
        popupMenuTheme: _darkPopupMenu,
      );

  // ════════════════════════════════════════════════════════════════════════════
  //  COLOR SCHEMES
  // ════════════════════════════════════════════════════════════════════════════

  static const ColorScheme _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.white,
    primaryContainer: AppColors.primaryContainer,
    onPrimaryContainer: AppColors.onPrimaryContainer,
    secondary: AppColors.secondary,
    onSecondary: AppColors.white,
    secondaryContainer: AppColors.secondaryContainer,
    onSecondaryContainer: AppColors.onSecondaryContainer,
    tertiary: Color(0xFF1565C0),
    onTertiary: AppColors.white,
    tertiaryContainer: Color(0xFFD3E4FF),
    onTertiaryContainer: Color(0xFF001A40),
    error: AppColors.error,
    onError: AppColors.white,
    errorContainer: AppColors.errorLight,
    onErrorContainer: Color(0xFF410002),
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    surfaceContainerHighest: AppColors.surfaceVariant,
    onSurfaceVariant: AppColors.textSecondary,
    outline: AppColors.border,
    outlineVariant: AppColors.divider,
    shadow: AppColors.black,
    scrim: AppColors.black,
    inverseSurface: AppColors.textPrimary,
    onInverseSurface: AppColors.white,
    inversePrimary: AppColors.darkPrimary,
    surfaceTint: AppColors.primary,
  );

  static const ColorScheme _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.darkPrimary,
    onPrimary: Color(0xFF003909),
    primaryContainer: AppColors.darkPrimaryContainer,
    onPrimaryContainer: AppColors.darkOnPrimaryContainer,
    secondary: AppColors.darkSecondary,
    onSecondary: Color(0xFF4A1700),
    secondaryContainer: AppColors.darkSecondaryContainer,
    onSecondaryContainer: AppColors.darkOnSecondaryContainer,
    tertiary: Color(0xFF90CAF9),
    onTertiary: Color(0xFF001A40),
    tertiaryContainer: Color(0xFF003A7A),
    onTertiaryContainer: Color(0xFFD3E4FF),
    error: Color(0xFFFF6B6B),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: AppColors.darkSurface,
    onSurface: AppColors.darkTextPrimary,
    surfaceContainerHighest: AppColors.darkSurfaceVariant,
    onSurfaceVariant: AppColors.darkTextSecondary,
    outline: AppColors.darkBorder,
    outlineVariant: AppColors.darkDivider,
    shadow: AppColors.black,
    scrim: AppColors.black,
    inverseSurface: AppColors.darkTextPrimary,
    onInverseSurface: AppColors.darkSurface,
    inversePrimary: AppColors.primary,
    surfaceTint: AppColors.darkPrimary,
  );

  // ════════════════════════════════════════════════════════════════════════════
  //  TEXT THEME
  // ════════════════════════════════════════════════════════════════════════════

  static TextTheme _textTheme(Brightness brightness) {
    final base = brightness == Brightness.light
        ? ThemeData.light().textTheme
        : ThemeData.dark().textTheme;
    return GoogleFonts.poppinsTextTheme(base).copyWith(
      displayLarge: GoogleFonts.poppins(
        fontSize: 57, fontWeight: FontWeight.w800, letterSpacing: -0.25,
        color: brightness == Brightness.light ? AppColors.textPrimary : AppColors.darkTextPrimary,
      ),
      headlineLarge: GoogleFonts.poppins(
        fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -0.5,
        color: brightness == Brightness.light ? AppColors.textPrimary : AppColors.darkTextPrimary,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.3,
        color: brightness == Brightness.light ? AppColors.textPrimary : AppColors.darkTextPrimary,
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: -0.2,
        color: brightness == Brightness.light ? AppColors.textPrimary : AppColors.darkTextPrimary,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 16, fontWeight: FontWeight.w600,
        color: brightness == Brightness.light ? AppColors.textPrimary : AppColors.darkTextPrimary,
      ),
      titleSmall: GoogleFonts.poppins(
        fontSize: 14, fontWeight: FontWeight.w600,
        color: brightness == Brightness.light ? AppColors.textPrimary : AppColors.darkTextPrimary,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 15, fontWeight: FontWeight.w400, height: 1.55,
        color: brightness == Brightness.light ? AppColors.textPrimary : AppColors.darkTextPrimary,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14, fontWeight: FontWeight.w400, height: 1.5,
        color: brightness == Brightness.light ? AppColors.textSecondary : AppColors.darkTextSecondary,
      ),
      bodySmall: GoogleFonts.poppins(
        fontSize: 12, fontWeight: FontWeight.w400,
        color: brightness == Brightness.light ? AppColors.textSecondary : AppColors.darkTextSecondary,
      ),
      labelLarge: GoogleFonts.poppins(
        fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1,
        color: brightness == Brightness.light ? AppColors.textPrimary : AppColors.darkTextPrimary,
      ),
      labelMedium: GoogleFonts.poppins(
        fontSize: 12, fontWeight: FontWeight.w500,
        color: brightness == Brightness.light ? AppColors.textSecondary : AppColors.darkTextSecondary,
      ),
      labelSmall: GoogleFonts.poppins(
        fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5,
        color: brightness == Brightness.light ? AppColors.textTertiary : AppColors.darkTextTertiary,
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  APP BAR
  // ════════════════════════════════════════════════════════════════════════════

  static final AppBarTheme _lightAppBar = AppBarTheme(
    centerTitle: true,
    elevation: 0,
    scrolledUnderElevation: 0.5,
    backgroundColor: AppColors.surface,
    surfaceTintColor: Colors.transparent,
    foregroundColor: AppColors.textPrimary,
    shadowColor: Colors.black.withValues(alpha: 0.08),
    titleTextStyle: GoogleFonts.poppins(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      letterSpacing: -0.1,
    ),
    iconTheme: const IconThemeData(color: AppColors.textPrimary, size: 22),
    actionsIconTheme: const IconThemeData(color: AppColors.textSecondary, size: 22),
    systemOverlayStyle: const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
      statusBarColor: Colors.transparent,
    ),
  );

  static final AppBarTheme _darkAppBar = AppBarTheme(
    centerTitle: true,
    elevation: 0,
    scrolledUnderElevation: 0.5,
    backgroundColor: AppColors.darkSurface,
    surfaceTintColor: Colors.transparent,
    foregroundColor: AppColors.darkTextPrimary,
    shadowColor: Colors.black.withValues(alpha: 0.3),
    titleTextStyle: GoogleFonts.poppins(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      color: AppColors.darkTextPrimary,
      letterSpacing: -0.1,
    ),
    iconTheme: const IconThemeData(color: AppColors.darkTextPrimary, size: 22),
    actionsIconTheme: const IconThemeData(color: AppColors.darkTextSecondary, size: 22),
    systemOverlayStyle: const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light,
      statusBarColor: Colors.transparent,
    ),
  );

  // ════════════════════════════════════════════════════════════════════════════
  //  CARD
  // ════════════════════════════════════════════════════════════════════════════

  static final CardThemeData _lightCard = CardThemeData(
    elevation: 0,
    color: AppColors.surface,
    surfaceTintColor: Colors.transparent,
    shadowColor: AppColors.shadowLight,
    shape: RoundedRectangleBorder(
      borderRadius: AppRadius.cardBR,
      side: const BorderSide(color: AppColors.border, width: 0.8),
    ),
    margin: EdgeInsets.zero,
  );

  static final CardThemeData _darkCard = CardThemeData(
    elevation: 0,
    color: AppColors.darkSurface,
    surfaceTintColor: Colors.transparent,
    shadowColor: AppColors.shadowDark,
    shape: RoundedRectangleBorder(
      borderRadius: AppRadius.cardBR,
      side: BorderSide.none,
    ),
    margin: EdgeInsets.zero,
  );

  // ════════════════════════════════════════════════════════════════════════════
  //  INPUT DECORATION
  // ════════════════════════════════════════════════════════════════════════════

  static final InputDecorationTheme _lightInput = InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surfaceVariant,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.inputPaddingH,
      vertical: AppSpacing.inputPaddingV,
    ),
    hintStyle: GoogleFonts.poppins(
      fontSize: 14,
      color: AppColors.textTertiary,
      fontWeight: FontWeight.w400,
    ),
    labelStyle: GoogleFonts.poppins(
      fontSize: 14,
      color: AppColors.textSecondary,
      fontWeight: FontWeight.w400,
    ),
    floatingLabelStyle: GoogleFonts.poppins(
      fontSize: 12,
      color: AppColors.primary,
      fontWeight: FontWeight.w500,
    ),
    border: OutlineInputBorder(
      borderRadius: AppRadius.inputBR,
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: AppRadius.inputBR,
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: AppRadius.inputBR,
      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: AppRadius.inputBR,
      borderSide: const BorderSide(color: AppColors.error, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: AppRadius.inputBR,
      borderSide: const BorderSide(color: AppColors.error, width: 1.5),
    ),
    errorStyle: GoogleFonts.poppins(fontSize: 11, color: AppColors.error),
  );

  static final InputDecorationTheme _darkInput = InputDecorationTheme(
    filled: true,
    fillColor: AppColors.darkSurfaceVariant,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.inputPaddingH,
      vertical: AppSpacing.inputPaddingV,
    ),
    hintStyle: GoogleFonts.poppins(
      fontSize: 14,
      color: AppColors.darkTextTertiary,
      fontWeight: FontWeight.w400,
    ),
    labelStyle: GoogleFonts.poppins(
      fontSize: 14,
      color: AppColors.darkTextSecondary,
      fontWeight: FontWeight.w400,
    ),
    floatingLabelStyle: GoogleFonts.poppins(
      fontSize: 12,
      color: AppColors.darkPrimary,
      fontWeight: FontWeight.w500,
    ),
    border: OutlineInputBorder(
      borderRadius: AppRadius.inputBR,
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: AppRadius.inputBR,
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: AppRadius.inputBR,
      borderSide: const BorderSide(color: AppColors.darkPrimary, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: AppRadius.inputBR,
      borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: AppRadius.inputBR,
      borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 1.5),
    ),
    errorStyle: GoogleFonts.poppins(fontSize: 11, color: Color(0xFFFF6B6B)),
  );

  // ════════════════════════════════════════════════════════════════════════════
  //  BUTTONS
  // ════════════════════════════════════════════════════════════════════════════

  static final ElevatedButtonThemeData _lightElevatedButton =
      ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      elevation: 0,
      shadowColor: Colors.transparent,
      minimumSize: const Size(double.infinity, AppSpacing.buttonHeightLg),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.buttonPaddingV, horizontal: AppSpacing.x24),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonBR),
      textStyle: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.2),
    ),
  );

  static final ElevatedButtonThemeData _darkElevatedButton =
      ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.darkPrimary,
      foregroundColor: const Color(0xFF003909),
      elevation: 0,
      shadowColor: Colors.transparent,
      minimumSize: const Size(double.infinity, AppSpacing.buttonHeightLg),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.buttonPaddingV, horizontal: AppSpacing.x24),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonBR),
      textStyle: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.2),
    ),
  );

  static final OutlinedButtonThemeData _outlinedButton =
      OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      side: const BorderSide(color: AppColors.primary, width: 1.2),
      minimumSize: const Size(double.infinity, AppSpacing.buttonHeightLg),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.buttonPaddingV, horizontal: AppSpacing.x24),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonBR),
      textStyle: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
    ),
  );

  static final TextButtonThemeData _textButton = TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primary,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x8, vertical: AppSpacing.x4),
      minimumSize: const Size(0, 0),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      textStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
    ),
  );

  // ════════════════════════════════════════════════════════════════════════════
  //  CHIP
  // ════════════════════════════════════════════════════════════════════════════

  static final ChipThemeData _lightChip = ChipThemeData(
    backgroundColor: AppColors.surfaceVariant,
    selectedColor: AppColors.primaryContainer,
    labelStyle: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
    secondaryLabelStyle: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.primary),
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x12, vertical: AppSpacing.x6),
    shape: RoundedRectangleBorder(borderRadius: AppRadius.chipBR),
    side: const BorderSide(color: AppColors.border, width: 0.8),
    elevation: 0,
    pressElevation: 0,
    showCheckmark: false,
  );

  static final ChipThemeData _darkChip = ChipThemeData(
    backgroundColor: AppColors.darkSurfaceVariant,
    selectedColor: AppColors.darkPrimaryContainer,
    labelStyle: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.darkTextPrimary),
    secondaryLabelStyle: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.darkPrimary),
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x12, vertical: AppSpacing.x6),
    shape: RoundedRectangleBorder(borderRadius: AppRadius.chipBR),
    side: BorderSide.none,
    elevation: 0,
    pressElevation: 0,
    showCheckmark: false,
  );

  // ════════════════════════════════════════════════════════════════════════════
  //  SWITCH
  // ════════════════════════════════════════════════════════════════════════════

  static final SwitchThemeData _lightSwitch = SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return AppColors.white;
      return AppColors.textTertiary;
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return AppColors.primary;
      return AppColors.border;
    }),
    trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
  );

  static final SwitchThemeData _darkSwitch = SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return AppColors.darkBackground;
      return AppColors.darkTextTertiary;
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return AppColors.darkPrimary;
      return AppColors.darkBorder;
    }),
    trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
  );

  // ════════════════════════════════════════════════════════════════════════════
  //  CHECKBOX
  // ════════════════════════════════════════════════════════════════════════════

  static final CheckboxThemeData _lightCheckbox = CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return AppColors.primary;
      return Colors.transparent;
    }),
    checkColor: WidgetStateProperty.all(AppColors.white),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    side: const BorderSide(color: AppColors.border, width: 1.5),
  );

  static final CheckboxThemeData _darkCheckbox = CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return AppColors.darkPrimary;
      return Colors.transparent;
    }),
    checkColor: WidgetStateProperty.all(AppColors.darkBackground),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    side: const BorderSide(color: AppColors.darkBorder, width: 1.5),
  );

  // ════════════════════════════════════════════════════════════════════════════
  //  TAB BAR
  // ════════════════════════════════════════════════════════════════════════════

  static final TabBarThemeData _lightTabBar = TabBarThemeData(
    labelColor: AppColors.primary,
    unselectedLabelColor: AppColors.textSecondary,
    indicatorColor: AppColors.primary,
    indicatorSize: TabBarIndicatorSize.label,
    dividerColor: AppColors.border,
    labelStyle: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
    unselectedLabelStyle: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w400),
    tabAlignment: TabAlignment.start,
  );

  static final TabBarThemeData _darkTabBar = TabBarThemeData(
    labelColor: AppColors.darkPrimary,
    unselectedLabelColor: AppColors.darkTextSecondary,
    indicatorColor: AppColors.darkPrimary,
    indicatorSize: TabBarIndicatorSize.label,
    dividerColor: AppColors.darkBorder,
    labelStyle: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
    unselectedLabelStyle: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w400),
    tabAlignment: TabAlignment.start,
  );

  // ════════════════════════════════════════════════════════════════════════════
  //  BOTTOM NAVIGATION BAR
  // ════════════════════════════════════════════════════════════════════════════

  static final BottomNavigationBarThemeData _lightBottomNav =
      BottomNavigationBarThemeData(
    type: BottomNavigationBarType.fixed,
    backgroundColor: AppColors.surface,
    selectedItemColor: AppColors.primary,
    unselectedItemColor: AppColors.textSecondary,
    elevation: 0,
    selectedLabelStyle:
        GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600),
    unselectedLabelStyle:
        GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w400),
    showSelectedLabels: true,
    showUnselectedLabels: true,
  );

  static final BottomNavigationBarThemeData _darkBottomNav =
      BottomNavigationBarThemeData(
    type: BottomNavigationBarType.fixed,
    backgroundColor: AppColors.darkSurface,
    selectedItemColor: AppColors.darkPrimary,
    unselectedItemColor: AppColors.darkTextSecondary,
    elevation: 0,
    selectedLabelStyle:
        GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600),
    unselectedLabelStyle:
        GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w400),
    showSelectedLabels: true,
    showUnselectedLabels: true,
  );

  // ════════════════════════════════════════════════════════════════════════════
  //  NAVIGATION BAR (M3)
  // ════════════════════════════════════════════════════════════════════════════

  static final NavigationBarThemeData _navigationBar = NavigationBarThemeData(
    elevation: 0,
    labelTextStyle: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600);
      }
      return GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w400);
    }),
    indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );

  // ════════════════════════════════════════════════════════════════════════════
  //  LIST TILE
  // ════════════════════════════════════════════════════════════════════════════

  static final ListTileThemeData _lightListTile = ListTileThemeData(
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.x16,
      vertical: AppSpacing.x4,
    ),
    minLeadingWidth: AppSpacing.x20,
    titleTextStyle: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
    ),
    subtitleTextStyle: GoogleFonts.poppins(
      fontSize: 12,
      color: AppColors.textSecondary,
    ),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
  );

  static final ListTileThemeData _darkListTile = ListTileThemeData(
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.x16,
      vertical: AppSpacing.x4,
    ),
    minLeadingWidth: AppSpacing.x20,
    titleTextStyle: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.darkTextPrimary,
    ),
    subtitleTextStyle: GoogleFonts.poppins(
      fontSize: 12,
      color: AppColors.darkTextSecondary,
    ),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
  );

  // ════════════════════════════════════════════════════════════════════════════
  //  DIVIDER
  // ════════════════════════════════════════════════════════════════════════════

  static const DividerThemeData _lightDivider = DividerThemeData(
    color: AppColors.divider,
    thickness: 0.8,
    space: 0,
  );

  static const DividerThemeData _darkDivider = DividerThemeData(
    color: AppColors.darkDivider,
    thickness: 0.8,
    space: 0,
  );

  // ════════════════════════════════════════════════════════════════════════════
  //  SNACK BAR
  // ════════════════════════════════════════════════════════════════════════════

  static final SnackBarThemeData _lightSnackBar = SnackBarThemeData(
    backgroundColor: AppColors.textPrimary,
    contentTextStyle: GoogleFonts.poppins(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: AppColors.white,
    ),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
    behavior: SnackBarBehavior.floating,
    insetPadding: const EdgeInsets.all(AppSpacing.x16),
    actionTextColor: AppColors.primaryLight,
    elevation: 4,
  );

  static final SnackBarThemeData _darkSnackBar = SnackBarThemeData(
    backgroundColor: AppColors.darkSurfaceElevated,
    contentTextStyle: GoogleFonts.poppins(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: AppColors.darkTextPrimary,
    ),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
    behavior: SnackBarBehavior.floating,
    insetPadding: const EdgeInsets.all(AppSpacing.x16),
    actionTextColor: AppColors.darkPrimary,
    elevation: 8,
  );

  // ════════════════════════════════════════════════════════════════════════════
  //  DIALOG
  // ════════════════════════════════════════════════════════════════════════════

  static final DialogThemeData _lightDialog = DialogThemeData(
    backgroundColor: AppColors.surface,
    surfaceTintColor: Colors.transparent,
    elevation: 8,
    shadowColor: Colors.black.withValues(alpha: 0.15),
    shape: RoundedRectangleBorder(borderRadius: AppRadius.dialogBR),
    titleTextStyle: GoogleFonts.poppins(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    contentTextStyle: GoogleFonts.poppins(
      fontSize: 14,
      color: AppColors.textSecondary,
      height: 1.5,
    ),
  );

  static final DialogThemeData _darkDialog = DialogThemeData(
    backgroundColor: AppColors.darkSurface,
    surfaceTintColor: Colors.transparent,
    elevation: 12,
    shadowColor: Colors.black.withValues(alpha: 0.4),
    shape: RoundedRectangleBorder(borderRadius: AppRadius.dialogBR),
    titleTextStyle: GoogleFonts.poppins(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      color: AppColors.darkTextPrimary,
    ),
    contentTextStyle: GoogleFonts.poppins(
      fontSize: 14,
      color: AppColors.darkTextSecondary,
      height: 1.5,
    ),
  );

  // ════════════════════════════════════════════════════════════════════════════
  //  BOTTOM SHEET
  // ════════════════════════════════════════════════════════════════════════════

  static final BottomSheetThemeData _bottomSheet = BottomSheetThemeData(
    modalElevation: 8,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: AppRadius.bottomSheetBR),
    showDragHandle: true,
    dragHandleColor: AppColors.border,
    dragHandleSize: const Size(36, 4),
    surfaceTintColor: Colors.transparent,
  );

  // ════════════════════════════════════════════════════════════════════════════
  //  FAB
  // ════════════════════════════════════════════════════════════════════════════

  static const FloatingActionButtonThemeData _lightFab =
      FloatingActionButtonThemeData(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.white,
    elevation: 4,
    shape: CircleBorder(),
  );

  static const FloatingActionButtonThemeData _darkFab =
      FloatingActionButtonThemeData(
    backgroundColor: AppColors.darkPrimary,
    foregroundColor: Color(0xFF003909),
    elevation: 6,
    shape: CircleBorder(),
  );

  // ════════════════════════════════════════════════════════════════════════════
  //  PROGRESS INDICATOR
  // ════════════════════════════════════════════════════════════════════════════

  static ProgressIndicatorThemeData _progressIndicator(Color color) =>
      ProgressIndicatorThemeData(color: color, linearTrackColor: color.withValues(alpha: 0.15));

  // ════════════════════════════════════════════════════════════════════════════
  //  ICON BUTTON
  // ════════════════════════════════════════════════════════════════════════════

  static final IconButtonThemeData _iconButton = IconButtonThemeData(
    style: IconButton.styleFrom(
      minimumSize: const Size(40, 40),
      padding: const EdgeInsets.all(AppSpacing.x8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
    ),
  );

  // ════════════════════════════════════════════════════════════════════════════
  //  POPUP MENU
  // ════════════════════════════════════════════════════════════════════════════

  static final PopupMenuThemeData _lightPopupMenu = PopupMenuThemeData(
    color: AppColors.surface,
    surfaceTintColor: Colors.transparent,
    elevation: 8,
    shadowColor: Colors.black.withValues(alpha: 0.12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
    textStyle: GoogleFonts.poppins(fontSize: 14, color: AppColors.textPrimary),
  );

  static final PopupMenuThemeData _darkPopupMenu = PopupMenuThemeData(
    color: AppColors.darkSurfaceElevated,
    surfaceTintColor: Colors.transparent,
    elevation: 12,
    shadowColor: Colors.black.withValues(alpha: 0.35),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
    textStyle: GoogleFonts.poppins(fontSize: 14, color: AppColors.darkTextPrimary),
  );
}
