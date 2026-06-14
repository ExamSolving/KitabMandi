import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/core/constants/app_color.dart';

class AppSnackbar {
  static void success(String message) {
    Get.snackbar(
      "Success",
      message,
      backgroundColor: AppColors.success,
      colorText: AppColors.white,
      snackPosition: SnackPosition.TOP,
      borderRadius: 12,
      margin: const EdgeInsets.all(12),
      icon: const Icon(Icons.check_circle, color: AppColors.white),
    );
  }

  static void error(String message) {
    Get.snackbar(
      "Error",
      message,
      backgroundColor: AppColors.error,
      colorText: AppColors.white,
      snackPosition: SnackPosition.TOP,
      borderRadius: 12,
      margin: const EdgeInsets.all(12),
      icon: const Icon(Icons.error, color: AppColors.white),
    );
  }
}
