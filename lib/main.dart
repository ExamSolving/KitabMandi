import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kitab_mandi/binding/initial_binding.dart';
import 'package:kitab_mandi/core/storage/location_storage.dart';
import 'package:kitab_mandi/core/themes/app_theme.dart';
import 'package:kitab_mandi/firebase_options.dart';
import 'package:kitab_mandi/routes/app_routes.dart';
import 'routes/app_pages.dart';
import 'core/controller/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Hive.initFlutter();

  ///  Use your storage init (clean approach)
  await LocationStorage.init();

  /// open location storage box
  await Hive.openBox('locationBox');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController controller = Get.put(
      ThemeController(),
      permanent: true,
    );

    return Obx(() {
      return GetMaterialApp(
        title: 'KitabMandi',
        debugShowCheckedModeBanner: false,

        //  THEMES
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,

        //  DYNAMIC THEME (FIXED)
        themeMode: controller.themeMode.value,

        //  ROUTING
        initialRoute: AppRoutes.splash,
        initialBinding: InitialBinding(),
        getPages: AppPages.routes,

        // ✨ UI POLISH
        defaultTransition: Transition.cupertino,
        popGesture: true,
      );
    });
  }
}
