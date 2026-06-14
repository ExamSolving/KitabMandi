import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class LanguageController extends GetxController {
  static const _boxName = 'settingsBox';
  static const _langKey = 'language';

  final RxString currentLang = 'en'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSavedLanguage();
  }

  void _loadSavedLanguage() {
    final box = Hive.box(_boxName);
    final saved = box.get(_langKey, defaultValue: 'en') as String;
    currentLang.value = saved;
    Get.updateLocale(_toLocale(saved));
  }

  Future<void> changeLanguage(String langCode) async {
    final box = Hive.box(_boxName);
    await box.put(_langKey, langCode);
    currentLang.value = langCode;
    Get.updateLocale(_toLocale(langCode));
  }

  Locale _toLocale(String code) =>
      code == 'hi' ? const Locale('hi', 'IN') : const Locale('en', 'US');

  bool get isEnglish => currentLang.value == 'en';
  bool get isHindi => currentLang.value == 'hi';
}
