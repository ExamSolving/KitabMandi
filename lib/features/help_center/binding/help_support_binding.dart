import 'package:get/get.dart';
import 'package:kitab_mandi/features/help_center/controller/help_support_controller.dart';

class HelpSupportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HelpSupportController>(
      () => HelpSupportController(),
      fenix: true,
    );
  }
}
