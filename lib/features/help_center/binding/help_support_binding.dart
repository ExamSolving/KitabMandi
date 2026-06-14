import 'package:get/get.dart';
import 'package:kitab_mandi/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:kitab_mandi/features/help_center/controller/help_support_controller.dart';
import 'package:kitab_mandi/features/help_center/domain/repositories/i_help_repository.dart';

class HelpSupportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HelpSupportController>(
      () => HelpSupportController(
        Get.find<IHelpRepository>(),
        Get.find<IAuthRepository>(),
      ),
      fenix: true,
    );
  }
}
