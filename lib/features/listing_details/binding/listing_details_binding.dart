import 'package:get/get.dart';
import 'package:kitab_mandi/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:kitab_mandi/features/listing/domain/repositories/i_listing_repository.dart';
import 'package:kitab_mandi/features/listing_details/controller/listing_details_controller.dart';

class ListingDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ListingDetailsController>(
      () => ListingDetailsController(
        Get.find<IListingRepository>(),
        Get.find<IAuthRepository>(),
      ),
      fenix: true,
    );
  }
}
