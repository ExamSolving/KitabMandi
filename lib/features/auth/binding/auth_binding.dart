import 'package:get/get.dart';
import 'package:kitab_mandi/features/auth/controller/auth_controller.dart';
import 'package:kitab_mandi/features/auth/domain/repositories/i_auth_repository.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // AuthController is already permanent from InitialBinding.
    // lazyPut is a no-op when the instance is already registered.
    Get.lazyPut<AuthController>(
      () => AuthController(Get.find<IAuthRepository>()),
      fenix: true,
    );
  }
}
