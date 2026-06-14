import 'package:get/get.dart';

class Validators {
  static String? validateEmail(String value) {
    if (value.isEmpty) return 'validate_email_required'.tr;
    if (!GetUtils.isEmail(value)) return 'validate_email_invalid'.tr;
    return null;
  }

  static String? validatePassword(String value) {
    if (value.isEmpty) return 'validate_password_required'.tr;
    if (value.length < 6) return 'validate_password_short'.tr;
    return null;
  }

  static String? validateName(String value) {
    if (value.isEmpty) return 'validate_name_required'.tr;
    if (value.length < 3) return 'validate_name_short'.tr;
    return null;
  }
}
