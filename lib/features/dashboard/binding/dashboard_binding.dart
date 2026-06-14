import 'package:get/get.dart';
import 'package:kitab_mandi/core/controller/filter_controller.dart';
import 'package:kitab_mandi/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:kitab_mandi/features/dashboard/controller/dashboard_controller.dart';
import 'package:kitab_mandi/features/dashboard/controller/my_ads_controller.dart';
import 'package:kitab_mandi/features/listing/domain/repositories/i_listing_repository.dart';
import 'package:kitab_mandi/features/wishlist/controller/wishlist_controller.dart';
import 'package:kitab_mandi/features/wishlist/domain/repositories/i_wishlist_repository.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(() => DashboardController(), fenix: true);
    Get.lazyPut<FilterController>(() => FilterController(), fenix: true);
    Get.lazyPut<MyAdsController>(
      () => MyAdsController(
        Get.find<IListingRepository>(),
        Get.find<IAuthRepository>(),
      ),
      fenix: true,
    );
    // WishlistController is also needed on the home screen (♥ toggle on cards)
    Get.lazyPut<WishlistController>(
      () => WishlistController(
        Get.find<IWishlistRepository>(),
        Get.find<IAuthRepository>(),
      ),
      fenix: true,
    );
  }
}
