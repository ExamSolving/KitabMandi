import 'package:get/get.dart';
import 'package:kitab_mandi/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:kitab_mandi/features/wishlist/controller/wishlist_controller.dart';
import 'package:kitab_mandi/features/wishlist/domain/repositories/i_wishlist_repository.dart';

class WishlistBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WishlistController>(
      () => WishlistController(
        Get.find<IWishlistRepository>(),
        Get.find<IAuthRepository>(),
      ),
      fenix: true,
    );
  }
}
