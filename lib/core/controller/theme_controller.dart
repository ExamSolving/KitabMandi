import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class ThemeController extends GetxController {
  static const _boxName = 'settingsBox';
  static const _themeKey = 'themeMode';

  final Rx<ThemeMode> themeMode = ThemeMode.system.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSavedTheme();
  }

  void _loadSavedTheme() {
    final box = Hive.box(_boxName);
    final saved = box.get(_themeKey, defaultValue: 'system') as String;
    switch (saved) {
      case 'dark':
        themeMode.value = ThemeMode.dark;
      case 'light':
        themeMode.value = ThemeMode.light;
      default:
        themeMode.value = ThemeMode.system;
    }
    Get.changeThemeMode(themeMode.value);
  }

  /// Returns whether dark mode is currently active (accounts for system pref).
  bool isDarkMode(BuildContext context) {
    if (themeMode.value == ThemeMode.system) {
      return MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    }
    return themeMode.value == ThemeMode.dark;
  }

  Future<void> toggleTheme(bool isDark) async {
    themeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
    Get.changeThemeMode(themeMode.value);
    final box = Hive.box(_boxName);
    await box.put(_themeKey, isDark ? 'dark' : 'light');
  }
}
