import 'package:get/get.dart';
import 'package:kitab_mandi/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:kitab_mandi/features/dashboard/controller/profile_controller.dart';
import 'package:kitab_mandi/features/user/domain/repositories/i_user_repository.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileController>(
      () => ProfileController(
        Get.find<IUserRepository>(),
        Get.find<IAuthRepository>(),
      ),
      fenix: true,
    );
  }
}
