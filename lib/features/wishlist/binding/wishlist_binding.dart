import 'package:get/get.dart';
import 'package:kitab_mandi/features/wishlist/controller/wishlist_controller.dart';

class WishlistBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WishlistController>(() => WishlistController(), fenix: true);
  }
}
