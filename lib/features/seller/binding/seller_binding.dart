import 'package:get/get.dart';
import 'package:kitab_mandi/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:kitab_mandi/features/listing/domain/repositories/i_listing_repository.dart';
import 'package:kitab_mandi/features/seller/controller/seller_controller.dart';

class SellerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SellerController>(
      () => SellerController(
        Get.find<IListingRepository>(),
        Get.find<IAuthRepository>(),
      ),
      fenix: true,
    );
  }
}
