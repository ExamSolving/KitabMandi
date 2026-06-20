import 'package:get/get.dart';
import 'package:kitab_mandi/features/resume/controller/cover_letter_controller.dart';
import 'package:kitab_mandi/features/resume/controller/resume_controller.dart';

class ResumeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ResumeController>(() => ResumeController());
    Get.lazyPut<CoverLetterController>(() => CoverLetterController());
  }
}
