import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class AppTranslations extends Translations {
  static Map<String, String> _en = {};
  static Map<String, String> _hi = {};

  static Future<void> load() async {
    final enRaw = await rootBundle.loadString('assets/translations/en.json');
    final hiRaw = await rootBundle.loadString('assets/translations/hi.json');
    _en = Map<String, String>.from(json.decode(enRaw));
    _hi = Map<String, String>.from(json.decode(hiRaw));
  }

  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': _en,
        'hi_IN': _hi,
      };
}
