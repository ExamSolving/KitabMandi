import 'package:get/get.dart';
import 'package:kitab_mandi/features/listing_details/controller/listing_details_controller.dart';

class ListingDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ListingDetailsController>(
      () => ListingDetailsController(),
      fenix: true,
    );
  }
}
