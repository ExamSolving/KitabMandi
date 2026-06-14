import 'package:get/get.dart';
import 'package:kitab_mandi/features/dashboard/controller/home_controller.dart';
import 'package:kitab_mandi/features/listing/domain/repositories/i_listing_repository.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(Get.find<IListingRepository>()),
      fenix: true,
    );
  }
}
