import 'package:get/get.dart';
import 'package:kitab_mandi/features/seller/controller/seller_controller.dart';

class SellerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SellerController>(() => SellerController(), fenix: true);
  }
}
