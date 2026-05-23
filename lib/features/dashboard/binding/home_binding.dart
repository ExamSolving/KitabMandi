import 'package:get/get.dart';
import 'package:kitab_mandi/features/dashboard/controller/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
  }
}
