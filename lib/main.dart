import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kitab_mandi/binding/initial_binding.dart';
import 'package:kitab_mandi/core/services/fcm_service.dart';
import 'package:kitab_mandi/core/storage/location_storage.dart';
import 'package:kitab_mandi/core/themes/app_theme.dart';
import 'package:kitab_mandi/core/translations/app_translations.dart';
import 'package:kitab_mandi/firebase_options.dart';
import 'package:kitab_mandi/routes/app_routes.dart';
import 'routes/app_pages.dart';
import 'core/controller/theme_controller.dart';
import 'core/controller/language_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Hive.initFlutter();
  await LocationStorage.init();
  await Hive.openBox('locationBox');
  await Hive.openBox('settingsBox');
  await AppTranslations.load();

  // FCM — must be set up before runApp so the background handler is registered
  // and getInitialMessage() captures the terminated-state notification tap.
  await FCMService.instance.initialize();

  // Register core UI controllers before runApp so the Obx wrapper in MyApp
  // can Get.find them immediately. InitialBinding skips these since they're
  // already registered (guarded with Get.isRegistered checks).
  Get.put<ThemeController>(ThemeController(), permanent: true);
  Get.put<LanguageController>(LanguageController(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCtrl = Get.find<ThemeController>();
    final langCtrl = Get.find<LanguageController>();

    return Obx(() {
      return GetMaterialApp(
        title: 'KitabMandi',
        debugShowCheckedModeBanner: false,

        // THEMES
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeCtrl.themeMode.value,

        // LOCALISATION
        translations: AppTranslations(),
        locale: langCtrl.currentLang.value == 'hi'
            ? const Locale('hi', 'IN')
            : const Locale('en', 'US'),
        fallbackLocale: const Locale('en', 'US'),

        // ROUTING
        initialRoute: AppRoutes.splash,
        initialBinding: InitialBinding(),
        getPages: AppPages.routes,

        defaultTransition: Transition.cupertino,
        popGesture: true,
      );
    });
  }
}
