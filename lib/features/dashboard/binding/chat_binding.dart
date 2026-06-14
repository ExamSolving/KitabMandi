import 'package:get/get.dart';
import 'package:kitab_mandi/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:kitab_mandi/features/chat/domain/repositories/i_chat_repository.dart';
import 'package:kitab_mandi/features/dashboard/controller/chat_controller.dart';

class ChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatController>(
      () => ChatController(
        Get.find<IChatRepository>(),
        Get.find<IAuthRepository>(),
      ),
      fenix: true,
    );
  }
}
