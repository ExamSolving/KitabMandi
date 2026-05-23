import 'package:get/get.dart';
import 'package:kitab_mandi/core/controller/filter_controller.dart';
import 'package:kitab_mandi/features/dashboard/controller/dashboard_controller.dart';
import 'package:kitab_mandi/features/dashboard/controller/my_ads_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(() => DashboardController(), fenix: true);
    Get.lazyPut<FilterController>(() => FilterController(), fenix: true);
    Get.lazyPut<MyAdsController>(() => MyAdsController(), fenix: true);
  }
}
