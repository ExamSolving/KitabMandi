import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeController extends GetxController {
  var themeMode = ThemeMode.system.obs;

  /// ✅ REAL DARK MODE (includes system dark)
  bool isDarkMode(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;

    if (themeMode.value == ThemeMode.system) {
      return brightness == Brightness.dark;
    }

    return themeMode.value == ThemeMode.dark;
  }

  /// Toggle manual mode
  void toggleTheme(bool isDark) {
    themeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
    Get.changeThemeMode(themeMode.value);
  }

  /// Optional: force sync on app start
  void initTheme(BuildContext context) {
    if (themeMode.value == ThemeMode.system) {
      Get.changeThemeMode(ThemeMode.system);
    }
  }
}
