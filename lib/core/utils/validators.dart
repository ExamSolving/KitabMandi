import 'package:get/get.dart';

class Validators {
  static String? validateEmail(String value) {
    if (value.isEmpty) return "Email is required";

    if (!GetUtils.isEmail(value)) {
      return "Enter a valid email";
    }
    return null;
  }

  static String? validatePassword(String value) {
    if (value.isEmpty) return "Password is required";

    if (value.length < 6) {
      return "Password must be at least 6 characters";
    }
    return null;
  }

  static String? validateName(String value) {
    if (value.isEmpty) return "Name is required";
    if (value.length < 3) return "Name too short";
    return null;
  }
}
