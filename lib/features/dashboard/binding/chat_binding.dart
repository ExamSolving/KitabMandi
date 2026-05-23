import 'package:get/get.dart';
import 'package:kitab_mandi/features/dashboard/controller/chat_controller.dart';

class ChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatController>(() => ChatController(), fenix: true);
  }
}
